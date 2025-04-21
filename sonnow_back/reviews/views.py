from rest_framework.permissions import AllowAny, IsAuthenticated

from .models import Review, Tag, ReactionReview, ReactionType
from rest_framework.generics import ListCreateAPIView, ListAPIView, DestroyAPIView, get_object_or_404
from .serializers import ReviewSerializer, TagSerializer, ReactionReviewSerializer, ReactionTypeSerializer
from rest_framework.response import Response
from rest_framework import status


class ReactionTypeListView(ListAPIView):
    """Liste tous les types de réactions disponibles"""
    queryset = ReactionType.objects.all()
    serializer_class = ReactionTypeSerializer
    permission_classes = [AllowAny]


class ReviewReactionsListView(ListAPIView):
    """Liste toutes les réactions pour une review spécifique"""
    serializer_class = ReactionReviewSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        return ReactionReview.objects.filter(review_id=self.kwargs['review_id'])


class AddReactionView(ListCreateAPIView):
    """Ajoute une réaction à une review"""
    serializer_class = ReactionReviewSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return ReactionReview.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        review_id = self.kwargs.get('review_id')
        emoji = request.data.get('emoji')

        # Vérifier si la review existe
        review = get_object_or_404(Review, id=review_id)

        # Vérifier si l'utilisateur a déjà cette réaction sur cette review
        existing_reaction = ReactionReview.objects.filter(
            user=request.user,
            review=review,
            emoji=emoji
        )

        if existing_reaction.exists():
            return Response(
                {"error": "You already have this reaction on this review"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Créer la réaction
        data = {
            'review': review_id,
            'emoji': emoji
        }

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user, review=review)

        return Response(serializer.data, status=status.HTTP_201_CREATED)


class RemoveReactionView(DestroyAPIView):
    """Supprime une réaction d'une review"""
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return ReactionReview.objects.filter(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        reaction_id = self.kwargs.get('reaction_id')

        reaction = get_object_or_404(
            ReactionReview,
            id=reaction_id,
        )

        reaction.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ReviewListView(ListAPIView):
    serializer_class = ReviewSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        return Review.objects.filter(release_id=self.kwargs['release_id'])


class ReviewListCreateView(ListCreateAPIView):
    serializer_class = ReviewSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Review.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        data = request.data.copy()
        data['user'] = request.user.id
        serializer = self.get_serializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class TagView(ListCreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = TagSerializer
    queryset = Tag.objects.all()
