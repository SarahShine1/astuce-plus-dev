from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from astuces.views import (
    AstuceViewSet, PropositionViewSet, ValidationViewSet,
    EvaluationViewSet, FavoriViewSet, RechercheViewSet
)
from users.views import RegisterView, UserViewSet
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
router.register(r'users', UserViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/auth/register/', RegisterView.as_view(), name='register'),
    path('api/auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
