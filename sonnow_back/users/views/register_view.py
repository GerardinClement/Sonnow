from django.http import JsonResponse
from django.middleware.csrf import get_token
from django.utils.decorators import method_decorator
from django.views import View
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_protect
from django.views.decorators.http import require_http_methods
from rest_framework.views import APIView

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
        if all(key in data for key in required_keys):
            user = User.objects.create_user(data.get('username'), data.get('email'), data.get('password'))
            user.save()
            return JsonResponse({'status': 'success'}, status=201)
        else:
            return JsonResponse({'status': 'error'}, status=400)

