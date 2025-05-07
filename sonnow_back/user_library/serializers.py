from rest_framework import serializers
from .models import LikedRelease, ToListenRelease, LikedArtist
from releases.serializers import ReleaseSerializer
from releases.models import Release
from artists.serializers import ArtistSerializer
from artists.models import Artist
from user_profile.models import Profile

class SimpleProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Profile
        fields = ['id', 'username', 'display_name', 'profile_picture']

class LikedReleaseSerializer(serializers.ModelSerializer):
    release = ReleaseSerializer(read_only=True)
    user = SimpleProfileSerializer(source='user.profile', read_only=True)

    class Meta:
        model = LikedRelease
        fields = ['id', 'user', 'release', 'date_added']
        read_only_fields = ['user', 'date_added']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        validated_data['release'] = Release.objects.get(id=self._kwargs['data']['release']['id'])
        return super().create(validated_data)

class LikedArtistSerializer(serializers.ModelSerializer):
    artist = ArtistSerializer(read_only=True)
    user = SimpleProfileSerializer(source='user.profile', read_only=True)

    class Meta:
        model = LikedArtist
        fields = ['id', 'user', 'artist', 'date_added']
        read_only_fields = ['user', 'date_added']

    def create(self, validated_data):
        request = self.context['request']
        artist_id = self._kwargs['data']['id']['id']
        artist = Artist.objects.get(id=artist_id)
        liked_artist = LikedArtist.objects.create(user=request.user, artist=artist)
        return liked_artist

class ToListenSerializer(serializers.ModelSerializer):
    release = ReleaseSerializer(read_only=True)
    user = SimpleProfileSerializer(source='user.profile', read_only=True)

    class Meta:
        model = ToListenRelease
        fields = ['id', 'user', 'release', 'date_added']
        read_only_fields = ['user', 'date_added']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        validated_data['release'] = Release.objects.get(id=self._kwargs['data']['release']['id'])
        return super().create(validated_data)
