from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Astuce, Categorie, Proposition, Validation, Evaluation, Favori, Recherche
from .serializers import (
    AstuceSerializer, CategorieSerializer, PropositionSerializer,
    ValidationSerializer, EvaluationSerializer, FavoriSerializer, RechercheSerializer
)
from django.utils import timezone
from django.contrib.auth import get_user_model

User = get_user_model()

class IsModerator(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.role == 'moderateur'

class AstuceViewSet(viewsets.ModelViewSet):
    queryset = Astuce.objects.all()
    serializer_class = AstuceSerializer

    def get_permissions(self):
        if self.action in ['create']:
            return [permissions.IsAuthenticated()]
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsModerator()]
        return [permissions.AllowAny()]

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def evaluer(self, request, pk=None):
        astuce = self.get_object()
        serializer = EvaluationSerializer(data=request.data)
        if serializer.is_valid():
            # prevent duplicate evaluations due to unique_together
            serializer.save(utilisateur=request.user, astuce=astuce)
            # mettre à jour score et nombre_votes
            evaluations = astuce.evaluations.all()
            total = sum(e.note for e in evaluations)
            astuce.nombre_votes = evaluations.count()
            astuce.score_fiabilite = total / astuce.nombre_votes if astuce.nombre_votes else 0
            astuce.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PropositionViewSet(viewsets.ModelViewSet):
    queryset = Proposition.objects.all()
    serializer_class = PropositionSerializer

    def get_permissions(self):
        if self.action in ['create']:
            return [permissions.IsAuthenticated()]
        if self.action in ['destroy']:
            return [IsModerator()]
        return [permissions.AllowAny()]

    def perform_create(self, serializer):
        serializer.save(utilisateur=self.request.user)

class ValidationViewSet(viewsets.ModelViewSet):
    queryset = Validation.objects.all()
    serializer_class = ValidationSerializer
    permission_classes = [IsModerator]

    def perform_create(self, serializer):
        # Lorsqu'un modérateur accepte, on marque l'astuce comme validée
        validation = serializer.save(moderateur=self.request.user)
        astuce = validation.astuce
        if validation.statut == 'acceptee':
            astuce.valide = True
            astuce.date_validation = timezone.now()
            astuce.save()
        else:
            astuce.valide = False
            astuce.save()

class EvaluationViewSet(viewsets.ModelViewSet):
    queryset = Evaluation.objects.all()
    serializer_class = EvaluationSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(utilisateur=self.request.user)

class FavoriViewSet(viewsets.ModelViewSet):
    queryset = Favori.objects.all()
    serializer_class = FavoriSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(utilisateur=self.request.user)

class RechercheViewSet(viewsets.ModelViewSet):
    queryset = Recherche.objects.all()
    serializer_class = RechercheSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(utilisateur=self.request.user)
