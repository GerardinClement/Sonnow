from rest_framework import serializers
from .models import LikedRelease, ToListenRelease, LikedArtist
from releases.serializers import ReleaseSerializer
from releases.models import Release

class LikedReleaseSerializer(serializers.ModelSerializer):
    release = ReleaseSerializer(read_only=True)

    class Meta:
        model = LikedRelease
        fields = ['id', 'user', 'release', 'date_added']
        read_only_fields = ['user', 'date_added']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        validated_data['release'] = Release.objects.get(release_id=self._kwargs['data']['release']['release_id'])
        return super().create(validated_data)

class LikedArtistSerializer(serializers.ModelSerializer):
    class Meta:
        model = LikedArtist
        fields = ['id', 'user', 'artist_id', 'date_added']
        read_only_fields = ['user', 'date_added']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

class ToListenSerializer(serializers.ModelSerializer):
    release = ReleaseSerializer(read_only=True)

    class Meta:
        model = ToListenRelease
        fields = ['id', 'user', 'release', 'date_added']
        read_only_fields = ['user', 'date_added']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        validated_data['release'] = Release.objects.get(release_id=self._kwargs['data']['release']['release_id'])
        return super().create(validated_data)
