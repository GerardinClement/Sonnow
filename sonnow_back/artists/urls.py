from django.urls import path
from .views import ArtistListCreateView, ArtistDetailView

urlpatterns = [
    path('', ArtistListCreateView.as_view(), name='artist-list'),
    path('<str:artist_id>/', ArtistDetailView.as_view(), name='artist-detail'),
]