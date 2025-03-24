from django.db import IntegrityError
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_protect
from rest_framework import status
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Review

required_keys = ['rating']

class ReviewView(APIView):

    @method_decorator(csrf_protect)
    def post(self, request, id):
        if not request.user.is_authenticated:
            return Response(status=status.HTTP_401_UNAUTHORIZED)
        data = request.data
        if not all(key in data for key in required_keys):
            return Response(status=status.HTTP_400_BAD_REQUEST)
        try:
            Review.objects.create(
                user=request.user,
                release_id=id,
                content=data['content'] or "",
                rating=data['rating'],
            )
            return Response(status=status.HTTP_201_CREATED)
        except IntegrityError as e:
            return Response(status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, id):
        reviews = Review.objects.filter(release_id=id)
        return Response([{
            'release_id': review.release_id,
            'user': review.user.username,
            'content': review.content,
            'rating': review.rating,
        } for review in reviews])
        





