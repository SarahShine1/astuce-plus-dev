from django.contrib import admin
from django.urls import path, include
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
