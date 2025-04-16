from django.http import JsonResponse
from django.middleware.csrf import get_token
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_protect
from django.views.decorators.http import require_http_methods
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from users.utils import decode_json_body
from django.contrib.auth.models import User

required_keys = ['username', 'email', 'password']

@ensure_csrf_cookie
@require_http_methods(["GET"])
def get_csrf_token(request):
    return JsonResponse({'message': 'CSRF cookie set'})

class RegisterView(APIView):

    @method_decorator(csrf_protect)
    def post(self, request):
        data = request.data
        if isinstance(data, JsonResponse):
            return data

        if not all(key in data for key in required_keys):
            return Response({'status': 'error', 'message': 'Invalid request'},
                            status=status.HTTP_400_BAD_REQUEST)

        username = data.get('username')
        email = data.get('email')
        password = data.get('password')

        if User.objects.filter(username=username).exists():
            return Response({'status': 'error', 'message': 'This username is already taken'},
                           status=status.HTTP_400_BAD_REQUEST)

        try:
            validate_email(email)
        except ValidationError:
            return Response({'status': 'error', 'message': 'This email format is not valid'},
                           status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email=email).exists():
            return Response({'status': 'error', 'message': 'This email is already taken'},
                           status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User(username=username, email=email)
            validate_password(password, user)
        except ValidationError as e:
            return Response({'status': 'error', 'message': e.messages},
                           status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.create_user(username, email, password)

            refresh = RefreshToken.for_user(user)

            return Response({
                'status': 'success',
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'status': 'error', 'message': str(e)},
                           status=status.HTTP_400_BAD_REQUEST)