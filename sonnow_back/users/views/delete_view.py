from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_protect


class DeleteAccountView(APIView):
    permission_classes = [IsAuthenticated]

    @method_decorator(csrf_protect)
    def delete(self, request):
        user = request.user
        password = request.data.get('password')

        # Vérifier que l'utilisateur a fourni son mot de passe pour confirmation
        if not password:
            return Response(
                {'error': 'You must provide your password to confirm account deletion'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Vérifier que le mot de passe est correct
        if not user.check_password(password):
            return Response(
                {'error': 'Incorrect password'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Supprimer l'utilisateur
        try:
            user.delete()
            return Response(
                {'status': 'success', 'message': 'Your account has been successfully deleted'},
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {'status': 'error', 'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )