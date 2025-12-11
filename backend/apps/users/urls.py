from django.contrib import admin
from django.urls import path, include
from . import views

from rest_framework import routers

from apps.users.views import RegisterView,LoginView, ProfileView
from rest_framework_simplejwt.views import (
    TokenObtainPairView, TokenRefreshView
)



urlpatterns = [
    path('login/', LoginView.as_view(), name='token_obtain_pair'),
    path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='register'),
    path('profile/', ProfileView.as_view(), name='profile'),
]
