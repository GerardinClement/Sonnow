from django.urls import path
from .views import (
    LikedReleaseListCreateView, LikedReleaseDeleteView,
    ToListenReleaseListCreateView, ToListenReleaseDeleteView,
    LikedArtistListCreateView, LikedArtistDeleteView
)

urlpatterns = [
     #Like release controller
    path('liked-releases/', LikedReleaseListCreateView.as_view(), name='liked-releases'),
    path('like-release/<str:release_id>/', LikedReleaseListCreateView.as_view(), name='like-release'),
    path('unlike-release/<str:release_id>/', LikedReleaseDeleteView.as_view(), name='unlike-release'),

    #To listen controller
    path('to-listen/', ToListenReleaseListCreateView.as_view(), name='to-listen'),
    path('to-listen/add/<str:release_id>/', ToListenReleaseListCreateView.as_view(), name='add-to-listen'),
    path('to-listen/delete/<str:release_id>/', ToListenReleaseDeleteView.as_view(), name='remove-to-listen'),

    #Liked artist controller
    path('liked-artists/', LikedArtistListCreateView.as_view(), name='liked-artists'),
    path('like-artist/<str:artist_id>/', LikedArtistListCreateView.as_view(), name='like-artist'),
    path('unlike-artist/<str:artist_id>/', LikedArtistDeleteView.as_view(), name='unlike-artist'),
]

