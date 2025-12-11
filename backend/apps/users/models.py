from django.db import models
from django.contrib.auth.models import AbstractUser

class CustomUser(AbstractUser):
    ROLE_INSCRIT = 'inscrit'
    ROLE_MODERATOR = 'moderateur'
    ROLE_INVITE = 'invite'

    ROLE_CHOICES = (
        (ROLE_INSCRIT, 'Inscrit'),
        (ROLE_MODERATOR, 'Modérateur'),
        (ROLE_INVITE, 'Invité'),
    )

    # Champs hérités d'AbstractUser: username, first_name, last_name, email, password, is_staff, is_active, etc.
    nom = models.CharField(max_length=150, blank=True)
    age = models.PositiveSmallIntegerField(null=True, blank=True)
    centres_interet = models.TextField(blank=True)  # liste séparée par des virgules ou JSON selon besoin
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default=ROLE_INSCRIT)
    date_creation = models.DateTimeField(auto_now_add=True)

    def is_moderator(self):
        return self.role == self.ROLE_MODERATOR

    def is_invite(self):
        return self.role == self.ROLE_INVITE

    def __str__(self):
        return self.username or self.email or str(self.id)
