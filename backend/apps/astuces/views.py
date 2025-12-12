from rest_framework import viewsets, permissions, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Avg, Q
from django.utils import timezone
from django.contrib.auth import get_user_model
from .models import Astuce, Categorie, Proposition, Validation, Evaluation, Favori, Recherche
from .serializers import (
    AstuceSerializer, CategorieSerializer, PropositionSerializer,
    ValidationSerializer, EvaluationSerializer, FavoriSerializer,
    RechercheSerializer, FavoriAvecAstuceSerializer
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

    @action(detail=True, methods=['get'])
    def details(self, request, pk=None):
        astuce = self.get_object()
        evaluations = astuce.evaluations.all()[:10]
        
        serializer = self.get_serializer(astuce)
        eval_serializer = EvaluationSerializer(evaluations, many=True)
        
        data = {
            'astuce': serializer.data,
            'evaluations': eval_serializer.data,
            'moyenne_note': astuce.evaluations.aggregate(Avg('note'))['note__avg'] or 0,
            'nombre_evaluations': astuce.evaluations.count(),
        }
        
        if request.user.is_authenticated:
            data['est_favori'] = astuce.favorited_by.filter(id=request.user.id).exists()
        
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
            favori.delete()
            return Response({'status': 'retiré des favoris'})
        
        return Response({'status': 'ajouté aux favoris'})

# ========== FAVORIS ==========
class FavoriViewSet(viewsets.ModelViewSet):
    queryset = Favori.objects.all()  # AJOUTÉ
    serializer_class = FavoriSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Favori.objects.filter(utilisateur=self.request.user)
    
    @action(detail=False, methods=['get'])
    def mes_favoris(self, request):
        favoris = self.get_queryset()
        serializer = FavoriAvecAstuceSerializer(favoris, many=True)
        return Response(serializer.data)

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
    
