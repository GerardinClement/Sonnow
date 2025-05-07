from django.urls import path
from .views import (
    ProfileView,
    RetrieveProfileView,
    ProfileSearchView,
    FollowProfileView,
    UnfollowProfileView,
    FollowedProfilesReviewsListView,
    FollowedProfilesLikedReleasesListView,
    FollowedProfilesLikedArtistsListView,
)

urlpatterns = [
    path('', ProfileView.as_view(), name='profile'),
    path('search/', ProfileSearchView.as_view(), name='profile-search'),
    path('followed-reviews/', FollowedProfilesReviewsListView.as_view(), name='followed-reviews'),
    path('followed-liked-releases/', FollowedProfilesLikedReleasesListView.as_view(), name='followed-liked-releases'),
    path('followed-liked-artists/', FollowedProfilesLikedArtistsListView.as_view(), name='followed-liked-artists'),
    path('<str:id>/', RetrieveProfileView.as_view(), name='retrieve-profile'),
    path('follow/<int:profile_id>/', FollowProfileView.as_view(), name='follow-profile'),
    path('unfollow/<int:profile_id>/', UnfollowProfileView.as_view(), name='unfollow-profile'),
]
