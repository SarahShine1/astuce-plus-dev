# Astuce+ - Application de partage d'astuces vérifiées

##  Contexte du projet
Application mobile développée dans le cadre d\'un stage au Laboratoire LMCS de l\'ESI (2024-2025).
Système de partage et validation collaborative d\'astuces pour la vie personnelle et professionnelle.

**Auteurs** : Bouchama Sarra & Meziane Anla  
**Encadrant** : M. Chalil Rachid  
**Laboratoire** : LMCS – ESI Alger  
**Année** : 2025-2026

## Architecture technique
- **Backend** : Django REST Framework (Python)
- **Frontend** : Flutter (Dart)
- **Base de données** : PostgreSQL
- **Authentification** : JWT Tokens
- **API** : REST

##  Installation et exécution

### Prérequis
- Python 3.8 ou supérieur
- Flutter SDK 3.0+
- PostgreSQL 13+
- Git
- Pip (gestionnaire de paquets Python)

### 1. Cloner le dépôt

git clone https://github.com/SarahShine1/astuce-plus-dev.git
cd astuce-plus-dev

### 2. Configuration du backend
cd backend

#### Créer un environnement virtuel
python -m venv venv

a. Activer l'environnement
 
venv\Scripts\activate (Windows)
source venv/bin/activate (Mac / Linux)

b. Installer les dépendances
pip install -r requirements.txt

### 3. Configuration de PostgreSQL
a. Installation

Télécharger PostgreSQL depuis le site officiel :
https://www.postgresql.org/download/

b. Création de la base de données
CREATE DATABASE astuce_plus;
CREATE USER astuce_user WITH PASSWORD 'astuce123';
GRANT ALL PRIVILEGES ON DATABASE astuce_plus TO astuce_user;
ALTER USER astuce_user WITH SUPERUSER;

c. Configuration de l’environnement
copy .env.example .env   # Windows

DEBUG=True
SECRET_KEY=votre-cle-secrete-ici
DATABASE_URL=postgresql://astuce_user:astuce123@localhost:5432/astuce_plus
ALLOWED_HOSTS=localhost,127.0.0.1

### 4. Migrations et lancement du serveur
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver


Backend accessible à :
http://localhost:8000

### 5.Configuration du frontend Flutter
- cd ..
- cd frontend
- flutter pub get
- flutter run

### 6.Données de démonstration
Option 1 : Créer des données manuellement
Connectez-vous à l'interface admin : http://localhost:8000/admin

Option 2 : Utiliser le script de peuplement 
Exécutez le script :
python populate_demo.py


