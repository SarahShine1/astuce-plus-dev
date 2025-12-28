from rest_framework import viewsets, permissions, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Avg, Q
from django.utils import timezone
from django.contrib.auth import get_user_model
from .models import Astuce, Categorie, Proposition, Validation, Evaluation, Favori, Recherche, Terme
from .serializers import (
    AstuceSerializer, CategorieSerializer, PropositionSerializer,
    ValidationSerializer, EvaluationSerializer, FavoriSerializer,
    RechercheSerializer, FavoriAvecAstuceSerializer, TermeSerializer
)

User = get_user_model()

# ========== PERMISSIONS ==========
class IsModerator(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and getattr(request.user, 'role', '') == 'moderateur'

# ========== CATEGORIES ==========
class CategorieViewSet(viewsets.ModelViewSet):
    queryset = Categorie.objects.all()
    serializer_class = CategorieSerializer
    permission_classes = [permissions.AllowAny]

# ========== ASTUCES ==========
class AstuceViewSet(viewsets.ModelViewSet):
    queryset = Astuce.objects.all()
    serializer_class = AstuceSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ['categories', 'valide', 'createur']
    ordering_fields = ['date_publication', 'score_fiabilite', 'nombre_votes']
    search_fields = ['titre', 'description']
    ordering = ['-date_publication']

    def get_permissions(self):
        if self.action in ['create', 'evaluer', 'toggle_favori']:
            return [permissions.IsAuthenticated()]
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsModerator()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        queryset = Astuce.objects.filter(valide=True)
        
        if self.request.user.is_authenticated and (self.request.user.is_staff or getattr(self.request.user, 'role', '') == 'moderateur'):
            queryset = Astuce.objects.all()
        
        return queryset

    def list(self, request, *args, **kwargs):
        """Override list to include request context"""
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        
        if page is not None:
            serializer = self.get_serializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def details(self, request, pk=None):
        astuce = self.get_object()
        evaluations = astuce.evaluations.all()[:10]
        
        # Serialize with context to get est_favori
        serializer = self.get_serializer(astuce, context={'request': request})
        eval_serializer = EvaluationSerializer(evaluations, many=True)

        # Check if current user has this in favorites
        est_favori = False
        if request.user.is_authenticated:
            est_favori = Favori.objects.filter(
                utilisateur=request.user,
                astuce=astuce
            ).exists()
        
        astuce_data = serializer.data
        astuce_data['est_favori'] = est_favori  # Ensure it's included
        
        data = {
            'astuce': astuce_data,
            'evaluations': eval_serializer.data,
            'moyenne_note': astuce.evaluations.aggregate(Avg('note'))['note__avg'] or 0,
            'nombre_evaluations': astuce.evaluations.count(),
        }
        
        return Response(data)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def evaluer(self, request, pk=None):
        astuce = self.get_object()
        
        existing_eval = Evaluation.objects.filter(utilisateur=request.user, astuce=astuce).first()
        if existing_eval:
            return Response(
                {'error': 'Vous avez déjà évalué cette astuce'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = EvaluationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(utilisateur=request.user, astuce=astuce)
            
            evaluations = astuce.evaluations.all()
            moyenne = evaluations.aggregate(Avg('note'))['note__avg'] or 0
            astuce.score_fiabilite = moyenne * 20
            astuce.nombre_votes = evaluations.count()
            astuce.save()
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def toggle_favori(self, request, pk=None):
        astuce = self.get_object()
        
        favori, created = Favori.objects.get_or_create(
            utilisateur=request.user,
            astuce=astuce
        )
        
        if not created:
            # If it already exists, delete it
            favori.delete()
            return Response({
                'message': 'Astuce retirée des favoris',
                'est_favori': False
            })
        else:
            # If newly created
            return Response({
                'message': 'Astuce ajoutée aux favoris',
                'est_favori': True
            })


# ========== FAVORIS ==========
class FavoriViewSet(viewsets.ModelViewSet):
    queryset = Favori.objects.all()
    serializer_class = FavoriSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Favori.objects.filter(utilisateur=self.request.user)
    
    @action(detail=False, methods=['get'])
    def mes_favoris(self, request):
        """Return the list of favorite astuces for the current user"""
        print(f"🔍 Fetching favorites for user: {request.user.username}")
        
        favoris = self.get_queryset().select_related('astuce')
        print(f"📊 Found {favoris.count()} favorites")
        
        # Extract the astuces from favoris
        astuces = [favori.astuce for favori in favoris]
        
        # Serialize the astuces with context
        serializer = AstuceSerializer(astuces, many=True, context={'request': request})
        
        # Add est_favori=True for all since these are all favorites
        data = serializer.data
        for astuce_data in data:
            astuce_data['est_favori'] = True
        
        print(f"✅ Returning {len(data)} favorite astuces")
        return Response(data)

# ========== PROPOSITIONS ==========
class PropositionViewSet(viewsets.ModelViewSet):
    queryset = Proposition.objects.all()
    serializer_class = PropositionSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        # Les utilisateurs normaux voient seulement leurs propositions
        # Les modérateurs voient toutes les propositions
        if self.request.user.is_authenticated and (self.request.user.is_staff or getattr(self.request.user, 'role', '') == 'moderateur'):
            return Proposition.objects.all()
        return Proposition.objects.filter(utilisateur=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(utilisateur=self.request.user)
    
    @action(detail=False, methods=['get'])
    def mes_propositions(self, request):
        propositions = self.get_queryset().filter(utilisateur=request.user)
        serializer = self.get_serializer(propositions, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], permission_classes=[IsModerator])
    def changer_statut(self, request, pk=None):
        proposition = self.get_object()
        nouveau_statut = request.data.get('statut')
        commentaire = request.data.get('commentaire_moderation', '')
        
        if nouveau_statut not in dict(Proposition.STATUT_CHOICES):
            return Response(
                {'error': 'Statut invalide'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        proposition.statut = nouveau_statut
        proposition.commentaire_moderation = commentaire
        proposition.save()
        
        # Si la proposition est acceptée, créer l'astuce correspondante
        if nouveau_statut == 'acceptee':
            astuce = Astuce.objects.create(
                titre=proposition.titre,
                description=proposition.description,
                source=proposition.source,
                valide=True,
                createur=proposition.utilisateur,
                date_publication=timezone.now(),
                date_validation=timezone.now(),
            )
            astuce.categories.set(proposition.categories.all())
            proposition.astuce = astuce
            proposition.save()
        
        serializer = self.get_serializer(proposition)
        return Response(serializer.data)
    
    
# ========== EVALUATIONS ==========
class EvaluationViewSet(viewsets.ModelViewSet):
    queryset = Evaluation.objects.all()  # AJOUTÉ
    serializer_class = EvaluationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Evaluation.objects.filter(utilisateur=self.request.user)

# ========== VALIDATIONS ==========
class ValidationViewSet(viewsets.ModelViewSet):
    queryset = Validation.objects.all()
    serializer_class = ValidationSerializer
    permission_classes = [IsModerator]

    def perform_create(self, serializer):
        validation = serializer.save(moderateur=self.request.user)
        astuce = validation.astuce
        
        if validation.statut == 'acceptee':
            astuce.valide = True
            astuce.date_validation = timezone.now()
        else:
            astuce.valide = False
        
        astuce.save()

# ========== RECHERCHE ==========
class RechercheViewSet(viewsets.ViewSet):
    permission_classes = [permissions.AllowAny]
    
    @action(detail=False, methods=['post'])
    def rechercher(self, request):
        mots_cles = request.data.get('mots_cles', '')
        categorie_id = request.data.get('categorie_id')
        
        if request.user.is_authenticated:
            Recherche.objects.create(
                mots_cles=mots_cles,
                utilisateur=request.user
            )
        
        if request.user.is_authenticated and (request.user.is_staff or getattr(request.user, 'role', '') == 'moderateur'):
            queryset = Astuce.objects.all()
        else:
            queryset = Astuce.objects.filter(valide=True)
        
        if mots_cles:
            queryset = queryset.filter(
                Q(titre__icontains=mots_cles) |
                Q(description__icontains=mots_cles)
            )
        
        if categorie_id:
            queryset = queryset.filter(categories__id=categorie_id)
        
        serializer = AstuceSerializer(queryset.order_by('-date_publication'), many=True)
        return Response({
            'results': serializer.data,
            'count': queryset.count()
        })


# ========== TERMES ==========
class TermeViewSet(viewsets.ModelViewSet):
    serializer_class = TermeSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['terme', 'definition']
    ordering_fields = ['terme', 'date_creation']
    ordering = ['terme']

    def get_queryset(self):
        # Only return terms from validated astuces
        return Terme.objects.filter(astuces__valide=True).distinct()

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [permissions.IsAuthenticated()]
        return [permissions.AllowAny()]
    
