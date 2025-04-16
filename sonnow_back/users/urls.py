from django.urls import path
from users.views.register_view import *
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView

from users.views.user_view import UserView, UserProfileUpdateView
from users.views.delete_view import DeleteAccountView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('update/', UserProfileUpdateView.as_view(), name="update"),
    path('delete/', DeleteAccountView.as_view(), name="delete"),
    path('csrf/', get_csrf_token),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # Login
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view()),
    path('info/', UserView.as_view(), name="info"),
]
