from django.urls import path
from .views import (
    LikedReleaseListCreateView, LikedReleaseDeleteView,
    ToListenReleaseListCreateView, ToListenReleaseDeleteView
)

urlpatterns = [
    path('liked-releases/', LikedReleaseListCreateView.as_view(), name='liked-releases'),
    path('<str:release_id>/like-release/', LikedReleaseListCreateView.as_view(), name='like-release'),
    path('<str:release_id>/liked-release/', LikedReleaseDeleteView.as_view(), name='unlike-release'),
    path('to-listen/', ToListenReleaseListCreateView.as_view(), name='to-listen'),
    path('<str:release_id>/to_listen/', ToListenReleaseDeleteView.as_view(), name='remove-to-listen'),
]
