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
    createur = serializers.StringRelatedField()
    est_favori = serializers.SerializerMethodField()
    
    class Meta:
        model = Astuce
        fields = [
            'id', 'titre', 'description', 'source', 
            'date_publication', 'valide', 'score_fiabilite',
            'nombre_votes', 'createur', 'categories', 'est_favori'
        ]
    
    def get_est_favori(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.favorited_by.filter(id=request.user.id).exists()
        return False

class PropositionSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)
    categories = CategorieSerializer(many=True, read_only=True)
    categories_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Categorie.objects.all(),
        source='categories',
        write_only=True,
        required=False
    )
    statut_display = serializers.CharField(source='get_statut_display', read_only=True)
    
    class Meta:
        model = Proposition
        fields = [
            'id', 'titre', 'description', 'source',
            'categories', 'categories_ids',
            'date', 'date_modification',
            'statut', 'statut_display',
            'commentaire_moderation',
            'utilisateur', 'astuce'
        ]
        read_only_fields = [
            'date', 'date_modification', 'statut',
            'commentaire_moderation', 'utilisateur', 'astuce'
        ]

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
        read_only_fields = ['date', 'utilisateur','astuce']

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


class FavoriAvecAstuceSerializer(serializers.ModelSerializer):
    astuce = AstuceSerializer(read_only=True)
    
    class Meta:
        model = Favori
        fields = ['id', 'date', 'astuce']