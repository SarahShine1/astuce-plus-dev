from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from . import views

from rest_framework import routers
from rest_framework_simplejwt.views import (
    TokenObtainPairView, TokenRefreshView
)



urlpatterns = [
    path('', views.home),  # page d’accueil temporaire
    path('admin/', admin.site.urls),
    path('api/users/', include('apps.users.urls')),
    path('api/astuces/', include('apps.astuces.urls')),  # API astuces 

]

# Servir les fichiers média en développement
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
