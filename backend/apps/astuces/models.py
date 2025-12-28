from django.db import models
from django.conf import settings

User = settings.AUTH_USER_MODEL

class Categorie(models.Model):
    nom = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.nom
    
# ✅ NOUVEAU: Modèle Terme pour le dictionnaire
class Terme(models.Model):
    terme = models.CharField(max_length=200, unique=True)
    definition = models.TextField()
    date_creation = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['terme']
    
    def __str__(self):
        return self.terme

class Astuce(models.Model):

    NIVEAU_CHOICES = (
        ('debutant', 'Débutant'),
        ('intermediaire', 'Intermédiaire'),
        ('expert', 'Expert'),
    )

    titre = models.CharField(max_length=255)
    description = models.TextField()
    source = models.CharField(max_length=255, blank=True, null=True)
    date_publication = models.DateTimeField(auto_now_add=True)
    #  NOUVEAU: Niveau de difficulté
    niveau_difficulte = models.CharField(
        max_length=20, 
        choices=NIVEAU_CHOICES, 
        default='debutant'
    )
    #  NOUVEAU: Image pour l'astuce
    image = models.ImageField(upload_to='astuces/%Y/%m/%d/', null=True, blank=True)

    valide = models.BooleanField(default=False)
    date_validation = models.DateTimeField(null=True, blank=True)

    score_ai = models.FloatField(null=True, blank=True)
    score_fiabilite = models.FloatField(default=0.0)  # moyenne calculée par les évaluations
    nombre_votes = models.PositiveIntegerField(default=0)

    createur = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='astuces_creees')
    categories = models.ManyToManyField(Categorie, blank=True, related_name='astuces')

    # ✅ NOUVEAU: Relation avec les termes du dictionnaire
    termes = models.ManyToManyField(Terme, blank=True, related_name='astuces')

    def __str__(self):
        return self.titre
    

    
# ✅ NOUVEAU: Modèle pour stocker les images d'une astuce
class ImageAstuce(models.Model):
    astuce = models.ForeignKey(Astuce, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='astuces/%Y/%m/%d/')
    legende = models.CharField(max_length=255, blank=True, null=True)
    ordre = models.PositiveIntegerField(default=0)
    date_ajout = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['ordre', 'date_ajout']
    
    def __str__(self):
        return f"Image {self.ordre} - {self.astuce.titre}"

class Proposition(models.Model):
    STATUT_CHOICES = (
        ('en_attente', 'En attente'),
        ('en_revision', 'En révision'),
        ('acceptee', 'Acceptée'),
        ('rejetee', 'Rejetée'),
    )

    NIVEAU_CHOICES = (
        ('debutant', 'Débutant'),
        ('intermediaire', 'Intermédiaire'),
        ('expert', 'Expert'),
    )
    
    titre = models.CharField(max_length=255)
    description = models.TextField()
    source = models.CharField(max_length=255, blank=True, null=True)
    # ✅ NOUVEAU: Image pour la proposition
    image = models.ImageField(upload_to='propositions/%Y/%m/%d/', null=True, blank=True)

    niveau_difficulte = models.CharField(max_length=20, choices=NIVEAU_CHOICES, default='debutant')
    categories = models.ManyToManyField(Categorie, blank=True, related_name='propositions')
    date = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    termes = models.ManyToManyField(Terme, blank=True, related_name='propositions')
    
    
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    commentaire_moderation = models.TextField(blank=True, null=True)
    
    utilisateur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='propositions')
    astuce = models.OneToOneField(Astuce, on_delete=models.SET_NULL, null=True, blank=True, related_name='proposition_origine')

    def __str__(self):
        return f"Proposition: {self.titre} - {self.get_statut_display()}"

class Validation(models.Model):
    STATUT_ACCEPT = 'acceptee'
    STATUT_REJECT = 'rejetee'
    STATUT_CHOICES = (
        (STATUT_ACCEPT, 'Acceptée'),
        (STATUT_REJECT, 'Rejetée'),
    )

    statut = models.CharField(max_length=20, choices=STATUT_CHOICES)
    date_validation = models.DateTimeField(auto_now_add=True)
    commentaire = models.TextField(blank=True, null=True)
    moderateur = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='validations')
    astuce = models.ForeignKey(Astuce, on_delete=models.CASCADE, related_name='validations')

    def __str__(self):
        return f"Validation {self.statut} - Astuce {self.astuce_id}"

class Evaluation(models.Model):
    note = models.PositiveSmallIntegerField()  # 1-5
    fiabilite_percue = models.FloatField(null=True, blank=True)  # 0.0-100.0 pourcentage
    commentaire = models.TextField(blank=True, null=True)
    date = models.DateTimeField(auto_now_add=True)
    utilisateur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='evaluations')
    astuce = models.ForeignKey(Astuce, on_delete=models.CASCADE, related_name='evaluations')

    class Meta:
        unique_together = ('utilisateur', 'astuce')  # un utilisateur évalue une astuce une seule fois

    def __str__(self):
        return f"Eval {self.note} par {self.utilisateur} sur {self.astuce}"

class Favori(models.Model):
    date = models.DateTimeField(auto_now_add=True)
    utilisateur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favoris')
    astuce = models.ForeignKey(Astuce, on_delete=models.CASCADE, related_name='favorited_by')

    class Meta:
        unique_together = ('utilisateur', 'astuce')

    def __str__(self):
        return f"Favori {self.utilisateur} -> {self.astuce}"

class Recherche(models.Model):
    mots_cles = models.CharField(max_length=255)
    date = models.DateTimeField(auto_now_add=True)
    utilisateur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='recherches')

    def __str__(self):
        return f"Recherche [{self.mots_cles}] par {self.utilisateur}"
