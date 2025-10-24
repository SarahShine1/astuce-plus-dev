from django.db import models
from django.conf import settings

User = settings.AUTH_USER_MODEL

class Categorie(models.Model):
    nom = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.nom

class Astuce(models.Model):
    titre = models.CharField(max_length=255)
    description = models.TextField()
    source = models.CharField(max_length=255, blank=True, null=True)
    date_publication = models.DateTimeField(auto_now_add=True)

    valide = models.BooleanField(default=False)
    date_validation = models.DateTimeField(null=True, blank=True)

    score_ai = models.FloatField(null=True, blank=True)
    score_fiabilite = models.FloatField(default=0.0)  # moyenne calculée par les évaluations
    nombre_votes = models.PositiveIntegerField(default=0)

    createur = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='astuces_creees')
    categories = models.ManyToManyField(Categorie, blank=True, related_name='astuces')

    def __str__(self):
        return self.titre

class Proposition(models.Model):
    contenu = models.TextField()
    date = models.DateTimeField(auto_now_add=True)
    utilisateur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='propositions')
    # Optionnel: lien vers une future astuce
    astuce = models.OneToOneField(Astuce, on_delete=models.SET_NULL, null=True, blank=True, related_name='proposition_origine')

    def __str__(self):
        return f"Proposition {self.id} par {self.utilisateur}"

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
