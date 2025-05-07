from django.urls import path
from .views import ReleaseListCreateView, ReleaseRetrieveView, ReleaseNumberOfLikesView

urlpatterns = [
    path('', ReleaseListCreateView.as_view(), name='release-list-create'),
    path('<str:release_id>/', ReleaseRetrieveView.as_view(), name='release-detail'),
    path('<str:release_id>/likes/', ReleaseNumberOfLikesView.as_view(), name='release-nb-of-likes'),
]
