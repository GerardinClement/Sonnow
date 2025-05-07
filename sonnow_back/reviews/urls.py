from django.urls import path
from reviews.views import ReviewListView, ReviewListCreateView, TagView, AddReactionView, RemoveReactionView, \
    ReviewReactionsListView, ReactionTypeListView, MostPopularReviewsListView

urlpatterns = [
    path('reaction-types/', ReactionTypeListView.as_view(), name='reaction-types-list'),
    path('<int:review_id>/react/<int:reaction_id>/', RemoveReactionView.as_view(), name='remove-reaction'),
    path('<int:review_id>/reactions/', ReviewReactionsListView.as_view(), name='review-reactions-list'),
    path('<int:review_id>/react/', AddReactionView.as_view(), name='add-reaction'),
    path('tags/', TagView.as_view(), name='review-tags'),
    path('most-popular/', MostPopularReviewsListView.as_view(), name='most-popular-reviews'),
    path('<str:release_id>/', ReviewListView.as_view(), name='release-reviews'),
    path('', ReviewListCreateView.as_view(), name='review-list-create'),

]
