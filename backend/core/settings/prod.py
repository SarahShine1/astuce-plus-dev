from .base import *

DEBUG = False

ALLOWED_HOSTS = ['your-domain.com', 'localhost']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'astuce_plus_prod',
        'USER': 'postgres',
        'PASSWORD': 'your-strong-password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
