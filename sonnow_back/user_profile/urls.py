from django.urls import path
from .views import ProfileView, ProfileSearchView, FollowProfileView, UnfollowProfileView

urlpatterns = [
    path('', ProfileView.as_view(), name='profile'),
    path('search/', ProfileSearchView.as_view(), name='profile-search'),
    path('follow/<int:profile_id>/', FollowProfileView.as_view(), name='follow-profile'),
    path('unfollow/<int:profile_id>/', UnfollowProfileView.as_view(), name='unfollow-profile'),
]
