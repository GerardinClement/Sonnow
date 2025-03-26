from rest_framework import serializers
from .models import LikedRelease, ToListenRelease, LikedArtist

class LikedReleaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = LikedRelease
        fields = ['id', 'user', 'release_id', 'date_added']
        read_only_fields = ['user', 'date_added']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

class LikedArtistSerializer(serializers.ModelSerializer):
    class Meta:
        model = LikedArtist
        fields = ['id', 'user', 'artist_id', 'date_added']
        read_only_fields = ['user', 'date_added']

class ToListenSerializer(serializers.ModelSerializer):
    class Meta:
        model = ToListenRelease
        fields = ['id', 'user', 'release_id', 'date_added']
        read_only_fields = ['user', 'date_added']
