from rest_framework import serializers
from .models import Astuce, Categorie, Proposition, Validation, Evaluation, Favori, Recherche , Terme
from django.conf import settings
from django.contrib.auth import get_user_model
import json

User = get_user_model()


# ========== CUSTOM FIELDS ==========
class JSONArrayField(serializers.Field):
    """
    Champ personnalisé qui accepte soit une liste, soit une string JSON
    Utile pour les multipart form-data où les arrays arrivent comme strings
    """
    def to_representation(self, value):
        return list(value)
    
    def to_internal_value(self, data):
        if isinstance(data, list):
            return data
        if isinstance(data, str):
            try:
                return json.loads(data)
            except json.JSONDecodeError:
                self.fail('invalid_json')
        self.fail('invalid_type')


class JSONField(serializers.Field):
    """
    Champ personnalisé qui accepte soit un dict/list, soit une string JSON
    Utile pour les multipart form-data où les objets JSON arrivent comme strings
    """
    def to_representation(self, value):
        return value
    
    def to_internal_value(self, data):
        if isinstance(data, (dict, list)):
            return data
        if isinstance(data, str):
            if not data.strip():  # Si string vide ou whitespace
                return []  # Retourner une liste vide
            try:
                parsed = json.loads(data)
                return parsed
            except json.JSONDecodeError as e:
                print(f"❌ JSON parse error: {e}")
                print(f"📝 Data received: {data}")
                raise serializers.ValidationError(f"Invalid JSON format: {str(e)}")
        raise serializers.ValidationError("Expected a JSON object, array, or JSON string")


# ========== TERME SERIALIZER ==========
class TermeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Terme
        fields = ['id', 'terme', 'definition', 'date_creation']
        read_only_fields = ['id', 'date_creation']

class CategorieSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categorie
        fields = ['id', 'nom']

class AstuceSerializer(serializers.ModelSerializer):
    categories = CategorieSerializer(many=True, read_only=True)
    createur = serializers.StringRelatedField()
    termes = TermeSerializer(many=True, read_only=True)
    est_favori = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    
    class Meta:
        model = Astuce
        fields = [
            'id', 'titre', 'description', 'source', 'date_publication',
            'niveau_difficulte', 'valide', 'date_validation', 'score_ai',
            'score_fiabilite', 'nombre_votes', 'createur', 'categories',
            'termes', 'est_favori', 'image', 'image_url', 'average_rating'
        ]

    read_only_fields = ['id', 'date_publication', 'valide', 'date_validation',
                           'score_ai', 'score_fiabilite', 'nombre_votes', 
                           'est_favori', 'image_url']
    
    def get_est_favori(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.favorited_by.filter(id=request.user.id).exists()
        return False
    
    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                url = request.build_absolute_uri(obj.image.url)
                print(f"🖼️  Astuce {obj.id} image_url: {url}")
                return url
            # Fallback: construire l'URL absolue même sans request
            # obj.image est déjà un ImageField avec le chemin partiel
            image_path = str(obj.image)
            if image_path.startswith('media/'):
                return f"http://192.168.137.1:8000/{image_path}"
            else:
                return f"http://192.168.137.1:8000/media/{image_path}"
        return None
    
    def get_average_rating(self, obj):
        """Calculate average rating from evaluations"""
        from django.db.models import Avg
        avg = obj.evaluations.aggregate(Avg('note'))['note__avg']
        return avg if avg else 0.0

class PropositionSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)
    categories = CategorieSerializer(many=True, read_only=True)
    categories_ids = JSONArrayField(
        write_only=True,
        required=False
    )
    termes_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Terme.objects.all(),
        source='termes',
        write_only=True,
        required=False
    )
    # Champ write-only pour créer de nouveaux termes
    nouveaux_termes = JSONField(
        write_only=True,
        required=False
    )
    
    # Champ read-only pour afficher les termes avec leurs définitions complètes
    termes = TermeSerializer(many=True, read_only=True)
    
    statut_display = serializers.CharField(source='get_statut_display', read_only=True)
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Proposition
        fields = [
            'id', 'titre', 'description', 'source', 'niveau_difficulte',
            'categories', 'categories_ids' , 
            'date', 'date_modification', 'statut', 'commentaire_moderation',
            'utilisateur', 'astuce' ,'termes', 'termes_ids', 'nouveaux_termes','statut_display',
            'image', 'image_url'
        ]
        read_only_fields = [
            'date', 'date_modification', 'statut',
            'commentaire_moderation', 'utilisateur', 'astuce', 'image_url'
        ]
    
    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                url = request.build_absolute_uri(obj.image.url)
                print(f"🖼️  Proposition {obj.id} image_url: {url}")
                return url
            # Fallback: construire l'URL absolue même sans request
            image_path = str(obj.image)
            if image_path.startswith('media/'):
                return f"http://192.168.137.1:8000/{image_path}"
            else:
                return f"http://192.168.137.1:8000/media/{image_path}"
        return None
    def create(self, validated_data):
        # Extraire les données des champs write-only
        categories_ids = validated_data.pop('categories_ids', [])  # Liste d'IDs
        termes_data = validated_data.pop('termes', [])  # Vient de termes_ids
        nouveaux_termes_data = validated_data.pop('nouveaux_termes', [])
        
        # Créer la proposition
        proposition = Proposition.objects.create(**validated_data)
        
        # Ajouter les catégories par IDs
        if categories_ids:
            try:
                categories = Categorie.objects.filter(id__in=categories_ids)
                proposition.categories.set(categories)
                print(f"✅ Catégories ajoutées: {list(categories.values_list('id', 'nom'))}")
            except Exception as e:
                print(f"❌ Erreur lors de l'ajout des catégories: {e}")
        
        # Ajouter les termes existants (par IDs)
        if termes_data:
            proposition.termes.set(termes_data)
        
        # Créer et ajouter les nouveaux termes
        if nouveaux_termes_data:
            for terme_dict in nouveaux_termes_data:
                terme, created = Terme.objects.get_or_create(
                    terme=terme_dict.get('terme', '').strip(),
                    defaults={
                        'definition': terme_dict.get('definition', '')
                    }
                )
                proposition.termes.add(terme)
    
        return proposition

class ValidationSerializer(serializers.ModelSerializer):
    moderateur = serializers.StringRelatedField(read_only=True)
    astuce = serializers.PrimaryKeyRelatedField(queryset=Astuce.objects.all())

    class Meta:
        model = Validation
        fields = ['id', 'statut', 'date_validation', 'commentaire', 'moderateur', 'astuce']
        read_only_fields = ['date_validation', 'moderateur']

class EvaluationSerializer(serializers.ModelSerializer):
    astuce = AstuceSerializer(read_only=True)
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

