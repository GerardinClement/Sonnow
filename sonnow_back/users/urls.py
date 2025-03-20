from django.urls import path
from users.views.register_view import *
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView, \
    TokenRefreshSlidingView

from users.views.user_view import UserView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('csrf/', get_csrf_token),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # Login
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view()),
    path('info/', UserView.as_view(), name="info")# Refresh token
]
