from django.contrib import admin
from django.urls import path, include
from . import views

from rest_framework import routers
from apps.astuces.views import (
    AstuceViewSet, PropositionViewSet, ValidationViewSet,
    EvaluationViewSet, FavoriViewSet, RechercheViewSet
)
from apps.users.views import RegisterView,LoginView, ProfileView
from rest_framework_simplejwt.views import (
    TokenObtainPairView, TokenRefreshView
)

router = routers.DefaultRouter()
router.register(r'astuces', AstuceViewSet)
router.register(r'propositions', PropositionViewSet)
router.register(r'validations', ValidationViewSet)
router.register(r'evaluations', EvaluationViewSet)
router.register(r'favoris', FavoriViewSet)
router.register(r'recherches', RechercheViewSet)


urlpatterns = [
    path('', views.home),  # page d’accueil temporaire
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/users/', include('apps.users.urls')),

]
