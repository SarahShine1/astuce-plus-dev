from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

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
