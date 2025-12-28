import os
import django
import sys
from datetime import datetime
from django.core.files.base import ContentFile
import random

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings.base')
django.setup()

from django.contrib.auth import get_user_model
from apps.users.models import CustomUser
from apps.astuces.models import Astuce, Categorie, Terme, Proposition, Evaluation, Favori, ImageAstuce

User = get_user_model()

print("🔧 Création des données de démonstration pour Astuce+...")
print("=" * 60)

# 1. Créer des catégories
print("\n📂 Création des catégories...")
categories_data = [
    'Productivité', 'Cuisine', 'Jardinage', 'Bricolage', 
    'Informatique', 'Santé', 'Économie', 'Éducation', 'Voyage',
    'Développement Personnel', 'Maison', 'Automobile'
]

for cat_name in categories_data:
    cat, created = Categorie.objects.get_or_create(nom=cat_name)
    if created:
        print(f'  ✅ Catégorie créée : {cat_name}')
    else:
        print(f'  ℹ️  Catégorie existe déjà : {cat_name}')

# 2. Créer des termes pour le dictionnaire
print("\n📚 Création des termes du dictionnaire...")
termes_data = [
    {
        'terme': 'Pomodoro',
        'definition': 'Technique de gestion du temps qui consiste à travailler par intervalles de 25 minutes (pomodoros) suivis de courtes pauses.'
    },
    {
        'terme': 'Responsive Design',
        'definition': 'Approche de conception web qui permet aux sites de s\'adapter à différentes tailles d\'écran.'
    },
    {
        'terme': 'API REST',
        'definition': 'Architecture de communication entre applications utilisant le protocole HTTP et les principes REST.'
    },
    {
        'terme': 'Framework',
        'definition': 'Ensemble cohérent de composants logiciels qui sert à créer les fondations d\'un logiciel.'
    },
    {
        'terme': 'JWT',
        'definition': 'JSON Web Token, standard ouvert pour transmettre des informations de manière sécurisée entre parties.'
    },
    {
        'terme': 'ORM',
        'definition': 'Object-Relational Mapping, technique de programmation pour convertir des données entre systèmes incompatibles.'
    }
]

for terme_data in termes_data:
    terme, created = Terme.objects.get_or_create(
        terme=terme_data['terme'],
        defaults={'definition': terme_data['definition']}
    )
    if created:
        print(f'  ✅ Terme créé : {terme_data["terme"]}')
    else:
        print(f'  ℹ️  Terme existe déjà : {terme_data["terme"]}')

# 3. Créer des utilisateurs
print("\n👤 Création des utilisateurs...")

# Super administrateur
admin_user, created = CustomUser.objects.get_or_create(
    username='admin',
    email='admin@astuce.com',
    defaults={
        'first_name': 'Admin',
        'last_name': 'Système',
        'is_staff': True,
        'is_superuser': True,
        'is_active': True,
        'role': 'moderateur',
        'bio': 'Administrateur principal de la plateforme Astuce+'
    }
)
if created:
    admin_user.set_password('admin123')
    admin_user.save()
    print('  ✅ Super administrateur créé')

# Utilisateur démo
demo_user, created = CustomUser.objects.get_or_create(
    username='demo_user',
    email='demo@astuce.com',
    defaults={
        'first_name': 'Jean',
        'last_name': 'Dupont',
        'is_active': True,
        'role': 'inscrit',
        'bio': 'Passionné de DIY et de productivité',
        'phone': '+33 6 12 34 56 78'
    }
)
if created:
    demo_user.set_password('demo123')
    demo_user.save()
    print('  ✅ Utilisateur démo créé')

# Expert
expert_user, created = CustomUser.objects.get_or_create(
    username='expert_tech',
    email='expert@astuce.com',
    defaults={
        'first_name': 'Marie',
        'last_name': 'Technique',
        'is_active': True,
        'role': 'expert',
        'bio': 'Experte en technologies et développement personnel',
        'phone': '+33 6 98 76 54 32'
    }
)
if created:
    expert_user.set_password('expert123')
    expert_user.save()
    print('  ✅ Utilisateur expert créé')

# 4. Créer des astuces
print("\n💡 Création des astuces...")

astuces_data = [
    {
        'titre': 'Technique Pomodoro pour la productivité',
        'description': 'Travaillez par sessions de 25 minutes suivies de pauses de 5 minutes. Après 4 sessions, prenez une pause plus longue de 15-30 minutes.',
        'source': 'Francesco Cirillo, 1992',
        'niveau_difficulte': 'debutant',
        'categories': ['Productivité', 'Développement Personnel'],
        'termes': ['Pomodoro'],
        'valide': True,
        'score_fiabilite': 4.5,
        'nombre_votes': 42
    },
    {
        'titre': 'Conserver les herbes fraîches plus longtemps',
        'description': 'Placez les herbes fraîches (persil, coriandre, basilic) dans un verre d\'eau, recouvrez d\'un sac plastique et conservez au réfrigérateur.',
        'source': 'Astuce de grand-mère',
        'niveau_difficulte': 'debutant',
        'categories': ['Cuisine'],
        'termes': [],
        'valide': True,
        'score_fiabilite': 4.2,
        'nombre_votes': 28
    },
    {
        'titre': 'Arrosage efficace des plantes d\'intérieur',
        'description': 'Arrosez le soir pour minimiser l\'évaporation. Utilisez de l\'eau à température ambiante et évitez l\'eau calcaire pour les plantes sensibles.',
        'source': 'Guide jardinage 2023',
        'niveau_difficulte': 'intermediaire',
        'categories': ['Jardinage', 'Maison'],
        'termes': [],
        'valide': True,
        'score_fiabilite': 4.0,
        'nombre_votes': 35
    },
    {
        'titre': 'Accélérer un ordinateur lent',
        'description': '1. Désactivez les programmes au démarrage\n2. Nettoyez le disque dur\n3. Ajoutez de la RAM si possible\n4. Mettez à jour les pilotes',
        'source': 'Guide informatique Microsoft',
        'niveau_difficulte': 'intermediaire',
        'categories': ['Informatique'],
        'termes': [],
        'valide': True,
        'score_fiabilite': 4.3,
        'nombre_votes': 56
    },
    {
        'titre': 'Économiser sur les courses alimentaires',
        'description': '1. Faites une liste de courses\n2. Achetez en vrac\n3. Privilégiez les produits de saison\n4. Comparez les prix au kilo',
        'source': 'Guide consommation responsable',
        'niveau_difficulte': 'debutant',
        'categories': ['Économie', 'Cuisine'],
        'termes': [],
        'valide': True,
        'score_fiabilite': 4.1,
        'nombre_votes': 39
    },
    {
        'titre': 'Apprendre une nouvelle langue efficacement',
        'description': '1. Pratiquez 15 minutes par jour\n2. Utilisez des applications comme Duolingo\n3. Regardez des films en VO\n4. Trouvez un partenaire linguistique',
        'source': 'Méthode polyglotte',
        'niveau_difficulte': 'expert',
        'categories': ['Éducation', 'Développement Personnel'],
        'termes': [],
        'valide': True,
        'score_fiabilite': 4.4,
        'nombre_votes': 47
    },
    {
        'titre': 'Voyager léger et efficace',
        'description': '1. Utilisez la méthode du rouleau pour plier les vêtements\n2. Emportez des vêtements multiusages\n3. Numérisez vos documents\n4. Privilégiez les échantillons de toilette',
        'source': 'Guide voyageur expérimenté',
        'niveau_difficulte': 'intermediaire',
        'categories': ['Voyage'],
        'termes': [],
        'valide': True,
        'score_fiabilite': 4.6,
        'nombre_votes': 31
    },
    {
        'titre': 'Réparer une fuite d\'eau temporairement',
        'description': 'Pour une petite fuite sur un tuyau, utilisez du ruban adhésif étanche ou de la pâte à joint. Solution temporaire en attendant le plombier.',
        'source': 'Guide bricolage d\'urgence',
        'niveau_difficulte': 'intermediaire',
        'categories': ['Bricolage', 'Maison'],
        'termes': [],
        'valide': True,
        'score_fiabilite': 3.8,
        'nombre_votes': 22
    }
]

for i, astuce_data in enumerate(astuces_data, 1):
    try:
        # Vérifier si l'astuce existe déjà
        existing_astuce = Astuce.objects.filter(titre=astuce_data['titre']).first()
        
        if not existing_astuce:
            # Créer l'astuce
            astuce = Astuce.objects.create(
                titre=astuce_data['titre'],
                description=astuce_data['description'],
                source=astuce_data['source'],
                niveau_difficulte=astuce_data['niveau_difficulte'],
                valide=astuce_data['valide'],
                score_fiabilite=astuce_data['score_fiabilite'],
                nombre_votes=astuce_data['nombre_votes'],
                createur=random.choice([demo_user, expert_user, admin_user]),
                date_validation=datetime.now() if astuce_data['valide'] else None
            )
            
            # Ajouter les catégories
            for cat_name in astuce_data['categories']:
                categorie = Categorie.objects.get(nom=cat_name)
                astuce.categories.add(categorie)
            
            # Ajouter les termes
            for terme_name in astuce_data['termes']:
                terme = Terme.objects.get(terme=terme_name)
                astuce.termes.add(terme)
            
            print(f'  ✅ Astuce {i} créée : {astuce_data["titre"]}')
            
            # Créer quelques évaluations pour cette astuce
            if astuce_data['nombre_votes'] > 0:
                for j in range(min(3, astuce_data['nombre_votes'])):
                    evaluateur = random.choice([demo_user, expert_user, admin_user])
                    note = random.randint(3, 5)
                    Evaluation.objects.create(
                        note=note,
                        fiabilite_percue=note * 20,  # Convertir note 1-5 en pourcentage
                        commentaire=f'Test d\'évaluation {j+1}',
                        utilisateur=evaluateur,
                        astuce=astuce
                    )
                
                # Marquer certains astuces comme favoris
                if random.random() > 0.5:  # 50% de chance
                    Favori.objects.get_or_create(
                        utilisateur=demo_user,
                        astuce=astuce
                    )
        else:
            print(f'  ℹ️  Astuce existe déjà : {astuce_data["titre"]}')
            
    except Exception as e:
        print(f'  ❌ Erreur création astuce "{astuce_data["titre"]}": {e}')

# 5. Créer quelques propositions
print("\n📝 Création des propositions...")

propositions_data = [
    {
        'titre': 'Nouvelle méthode d\'organisation du temps',
        'description': 'Je propose une variante de la technique Pomodoro avec des sessions de 45 minutes.',
        'source': 'Expérience personnelle',
        'niveau_difficulte': 'intermediaire',
        'categories': ['Productivité'],
        'statut': 'en_attente'
    },
    {
        'titre': 'Recette économique de soupe maison',
        'description': 'Utiliser les restes de légumes pour faire une soupe nutritive et économique.',
        'source': 'Recette familiale',
        'niveau_difficulte': 'debutant',
        'categories': ['Cuisine', 'Économie'],
        'statut': 'en_revision'
    }
]

for prop_data in propositions_data:
    try:
        prop, created = Proposition.objects.get_or_create(
            titre=prop_data['titre'],
            utilisateur=demo_user,
            defaults={
                'description': prop_data['description'],
                'source': prop_data['source'],
                'niveau_difficulte': prop_data['niveau_difficulte'],
                'statut': prop_data['statut']
            }
        )
        
        if created:
            # Ajouter les catégories
            for cat_name in prop_data['categories']:
                categorie = Categorie.objects.get(nom=cat_name)
                prop.categories.add(categorie)
            
            print(f'  ✅ Proposition créée : {prop_data["titre"]} ({prop_data["statut"]})')
        else:
            print(f'  ℹ️  Proposition existe déjà : {prop_data["titre"]}')
            
    except Exception as e:
        print(f'  ❌ Erreur création proposition "{prop_data["titre"]}": {e}')

# 6. Afficher le récapitulatif
print("\n" + "=" * 60)
print("📊 RÉCAPITULATIF DES DONNÉES CRÉÉES")
print("=" * 60)

print(f"\n📁 Catégories : {Categorie.objects.count()}")
print(f"📚 Termes : {Terme.objects.count()}")
print(f"👤 Utilisateurs : {CustomUser.objects.count()}")
print(f"💡 Astuces : {Astuce.objects.count()}")
print(f"📝 Propositions : {Proposition.objects.count()}")
print(f"⭐ Évaluations : {Evaluation.objects.count()}")
print(f"❤️  Favoris : {Favori.objects.count()}")

print("\n" + "=" * 60)
print("🎉 DONNÉES DE DÉMONSTRATION CRÉÉES AVEC SUCCÈS !")
print("=" * 60)

print("\n🔑 IDENTIFIANTS DE CONNEXION :")
print("  1. Super Administrateur :")
print("     - Email : admin@astuce.com")
print("     - Mot de passe : admin123")
print("     - Rôle : Modérateur & Superuser")
print()
print("  2. Utilisateur Démo :")
print("     - Email : demo@astuce.com")
print("     - Mot de passe : demo123")
print("     - Rôle : Inscrit")
print()
print("  3. Expert :")
print("     - Email : expert@astuce.com")
print("     - Mot de passe : expert123")
print("     - Rôle : Expert")

print("\n🌐 URLS IMPORTANTES :")
print("   - Backend API : http://localhost:8000/api/")
print("   - Interface Admin : http://localhost:8000/admin/")
print("   - Dictionnaire des termes : http://localhost:8000/api/termes/")

print("\n📱 POUR LANCER L'APPLICATION :")
print("   1. Backend (dans backend/) :")
print("      python manage.py runserver")
print()
print("   2. Frontend (dans frontend/) :")
print("      flutter run")

print("\n" + "=" * 60)
print("💡 ASTUCE :")
print("- Utilisez le compte admin pour gérer la modération")
print("- Utilisez le compte demo pour tester les fonctionnalités utilisateur")
print("- Toutes les astuces ont des évaluations et certaines sont en favoris")
print("=" * 60)