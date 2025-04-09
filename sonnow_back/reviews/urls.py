from django.urls import path
from reviews.views import ReviewListView, ReviewListCreateView, TagView

urlpatterns = [
    path('tags/', TagView.as_view(), name='review-tags'),
    path('<str:release_id>/', ReviewListView.as_view(), name='release-reviews'),
    path('', ReviewListCreateView.as_view(), name='review-list-create'),

]