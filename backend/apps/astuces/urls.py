from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'categories', views.CategorieViewSet, basename='categorie')
router.register(r'astuces', views.AstuceViewSet, basename='astuce')
router.register(r'propositions', views.PropositionViewSet, basename='proposition')
router.register(r'evaluations', views.EvaluationViewSet, basename='evaluation')
router.register(r'favoris', views.FavoriViewSet, basename='favori')
router.register(r'validations', views.ValidationViewSet, basename='validation')

urlpatterns = [
    path('', include(router.urls)),
    path('rechercher/', views.RechercheViewSet.as_view({'post': 'rechercher'}), name='rechercher'),
    path('astuces/<int:pk>/details/', views.AstuceViewSet.as_view({'get': 'details'}), name='astuce-details'),
    path('astuces/<int:pk>/evaluer/', views.AstuceViewSet.as_view({'post': 'evaluer'}), name='astuce-evaluer'),
    path('astuces/<int:pk>/toggle_favori/', views.AstuceViewSet.as_view({'post': 'toggle_favori'}), name='astuce-toggle-favori'),
    path('favoris/mes_favoris/', views.FavoriViewSet.as_view({'get': 'mes_favoris'}), name='mes-favoris'),
    path('propositions/mes_propositions/', views.PropositionViewSet.as_view({'get': 'mes_propositions'}), name='mes-propositions'),
    path('propositions/<int:pk>/changer_statut/', views.PropositionViewSet.as_view({'post': 'changer_statut'}), name='changer-statut'),
]