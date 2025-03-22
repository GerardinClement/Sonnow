from django.urls import path
from reviews.views import ReviewView

urlpatterns = [
    path('<str:id>/create/', ReviewView.as_view(), name='create'),
    path('<str:id>/', ReviewView.as_view(), name='get'),
]