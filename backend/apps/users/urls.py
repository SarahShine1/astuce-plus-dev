from django.contrib import admin
from django.urls import path, include
from . import views
from rest_framework.routers import DefaultRouter

from rest_framework import routers

from apps.users.views import RegisterView, LoginView, ProfileView, UserViewSet, UserAstucesView, UserEvaluationsView, UserPropositionsView, ChangePasswordView, ForgotPasswordView, ResetPasswordView
from rest_framework_simplejwt.views import (
    TokenObtainPairView, TokenRefreshView
)
router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')  # Changed from 'list' to 'users'


urlpatterns = [
    path('login/', LoginView.as_view(), name='token_obtain_pair'),
    path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='register'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),

    path('profile/astuces/', UserAstucesView.as_view(), name='user-astuces'),
    path('profile/evaluations/', UserEvaluationsView.as_view(), name='user-evaluations'),
    path('profile/propositions/', UserPropositionsView.as_view(), name='user-propositions'),
     path('', include(router.urls)), 
]
