from django.urls import path
from .views import ReleaseListCreateView, ReleaseRetrieveView

urlpatterns = [
    path('', ReleaseListCreateView.as_view(), name='release-list-create'),
    path('<str:release_id>/', ReleaseRetrieveView.as_view(), name='release-detail'),
]
