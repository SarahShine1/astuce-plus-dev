from .base import *

DEBUG = True

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '10.0.2.2',           # Pour émulateur Android
    '192.168.137.1'
]
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://192.168.137.1:8000",
]
   

# En développement, vous pouvez aussi utiliser:
CORS_ALLOW_ALL_ORIGINS = True  # Plus simple pour tests
# Si tu veux garder PostgreSQL aussi pour dev :
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'astuce_plus',
        'USER': 'postgres',
        'PASSWORD': '1234',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
