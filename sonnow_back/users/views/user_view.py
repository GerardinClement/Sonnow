from django.core.validators import validate_email
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_protect
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

class UserView(APIView):

    @method_decorator(csrf_protect)
    def get(self, request):
        if not request.user.is_authenticated:
            return Response(status=status.HTTP_401_UNAUTHORIZED)
        user = request.user
        return Response({
            "username": user.username,
            "email": user.email,
        })

class UserProfileUpdateView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request):
        user = request.user
        data = request.data

        # Mise à jour du username
        if 'username' in data and data['username'] != user.username:
            if User.objects.filter(username=data['username']).exists():
                return Response({'error': 'Username already taken'},
                                status=status.HTTP_400_BAD_REQUEST)
            user.username = data['username']

        # Mise à jour de l'email
        if 'email' in data and data['email'] != user.email:
            if User.objects.filter(email=data['email']).exists():
                return Response({'error': 'Email already taken'},
                                status=status.HTTP_400_BAD_REQUEST)
            try:
                validate_email(data['email'])
            except ValidationError:
                return Response({'error': 'Invalid email address'},
                                status=status.HTTP_400_BAD_REQUEST)
            user.email = data['email']

        # Mise à jour du mot de passe
        if 'new_password' in data and 'old_password' in data:
            if not user.check_password(data['old_password']):
                return Response({'error': 'Incorrect current password'}, status=status.HTTP_400_BAD_REQUEST)

            try:
                validate_password(data['new_password'], user)
                user.set_password(data['new_password'])
            except ValidationError as e:
                return Response({'error': e.messages}, status=status.HTTP_400_BAD_REQUEST)

        user.save()
        return Response({'status': 'success'}, status=status.HTTP_200_OK)


