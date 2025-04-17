from rest_framework import serializers, status
from rest_framework.response import Response
from .models import Profile
from artists.serializers import ArtistSerializer
from releases.serializers import ReleaseSerializer
from user_library.serializers import ToListenSerializer, LikedReleaseSerializer, LikedArtistSerializer


class SimpleProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Profile
        fields = ['id', 'username', 'display_name', 'profile_picture']


class ProfileSerializer(serializers.ModelSerializer):
    highlighted_artist = ArtistSerializer(read_only=True)
    highlighted_release = ReleaseSerializer(read_only=True)
    reviews = serializers.SerializerMethodField()
    profile_picture = serializers.SerializerMethodField()
    follows = SimpleProfileSerializer(many=True, read_only=True)
    followers = serializers.SerializerMethodField()

    highlighted_artist_id = serializers.IntegerField(write_only=True, required=False)
    highlighted_release_id = serializers.IntegerField(write_only=True, required=False)
    follows_ids = serializers.PrimaryKeyRelatedField(
        queryset=Profile.objects.all(),
        many=True,
        required=False,
        write_only=True
    )
    liked_releases = LikedReleaseSerializer(many=True, read_only=True)
    liked_artists = LikedArtistSerializer(many=True, read_only=True)
    to_listen_releases = ToListenSerializer(many=True, read_only=True)

    class Meta:
        model = Profile
        fields = [
            'id',
            'user',
            'display_name',
            'profile_picture',
            'bio',
            'highlighted_artist',
            'highlighted_artist_id',
            'highlighted_release',
            'highlighted_release_id',
            'reviews',
            'follows',
            'follows_ids',
            'followers',
            'liked_releases',
            'liked_artists',
            'to_listen_releases'
        ]
        read_only_fields = ['user']

    def get_followers(self, obj):
        return SimpleProfileSerializer(obj.followers.all(), many=True, context=self.context).data

    def update(self, instance, validated_data):
        highlighted_artist_id = validated_data.pop('highlighted_artist_id', None)
        highlighted_release_id = validated_data.pop('highlighted_release_id', None)
        follows_ids = validated_data.pop('follows_ids', None)

        if highlighted_artist_id is not None:
            from artists.models import Artist
            try:
                instance.highlighted_artist = Artist.objects.get(id=highlighted_artist_id)
            except Artist.DoesNotExist:
                return Response({'error': 'Artist not found'}, status=status.HTTP_404_NOT_FOUND)

        if highlighted_release_id is not None:
            from releases.models import Release
            try:
                instance.highlighted_release = Release.objects.get(id=highlighted_release_id)
            except Release.DoesNotExist:
                return Response({'error': 'Release not found'}, status=status.HTTP_404_NOT_FOUND)

        if follows_ids is not None:
            instance.follows.set(follows_ids)

        return super().update(instance, validated_data)

    def get_reviews(self, obj):
        from reviews.serializers import ReviewSerializer
        return ReviewSerializer(obj.reviews, many=True, context=self.context).data

    def get_profile_picture(self, obj):
        if obj.profile_picture:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_picture.url)
            return obj.profile_picture.url
        return None