
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_protect
from rest_framework.views import APIView

class LoginView(APIView):

    @method_decorator(csrf_protect)
    def post(self, request):
        data = request.data
        username = data.get('username')
        password = data.get('password')






