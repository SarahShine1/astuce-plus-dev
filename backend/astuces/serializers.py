from rest_framework import serializers
from .models import Astuce, Categorie, Proposition, Validation, Evaluation, Favori, Recherche
from django.conf import settings
from django.contrib.auth import get_user_model

User = get_user_model()

class CategorieSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categorie
        fields = ['id', 'nom']

class AstuceSerializer(serializers.ModelSerializer):
    categories = CategorieSerializer(many=True, read_only=True)
    createur = serializers.StringRelatedField()  # ou nested user serializer

    class Meta:
        model = Astuce
        fields = ['id', 'titre', 'description', 'source', 'date_publication', 'valide', 'date_validation',
                  'score_ai', 'score_fiabilite', 'nombre_votes', 'createur', 'categories']

class PropositionSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Proposition
        fields = ['id', 'contenu', 'date', 'utilisateur', 'astuce']
        read_only_fields = ['date', 'utilisateur', 'astuce']

class ValidationSerializer(serializers.ModelSerializer):
    moderateur = serializers.StringRelatedField(read_only=True)
    astuce = serializers.PrimaryKeyRelatedField(queryset=Astuce.objects.all())

    class Meta:
        model = Validation
        fields = ['id', 'statut', 'date_validation', 'commentaire', 'moderateur', 'astuce']
        read_only_fields = ['date_validation', 'moderateur']

class EvaluationSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Evaluation
        fields = ['id', 'note', 'fiabilite_percue', 'commentaire', 'date', 'utilisateur', 'astuce']
        read_only_fields = ['date', 'utilisateur']

class FavoriSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)
    astuce = serializers.PrimaryKeyRelatedField(queryset=Astuce.objects.all())

    class Meta:
        model = Favori
        fields = ['id', 'date', 'utilisateur', 'astuce']
        read_only_fields = ['date', 'utilisateur']

class RechercheSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Recherche
        fields = ['id', 'mots_cles', 'date', 'utilisateur']
        read_only_fields = ['date', 'utilisateur']
