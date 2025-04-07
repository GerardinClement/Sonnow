from rest_framework import serializers
from .models import Profile
from artists.serializers import ArtistSerializer
from releases.serializers import ReleaseSerializer

class ProfileSerializer(serializers.ModelSerializer):
    highlighted_artist = ArtistSerializer(read_only=True)
    highlighted_release = ReleaseSerializer(read_only=True)
    highlighted_artist_id = serializers.IntegerField(write_only=True, required=False)
    highlighted_release_id = serializers.IntegerField(write_only=True, required=False)

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
        ]
        read_only_fields = ['user']

    def update(self, instance, validated_data):
        highlighted_artist_id = validated_data.pop('highlighted_artist_id', None)
        highlighted_release_id = validated_data.pop('highlighted_release_id', None)

        if highlighted_artist_id is not None:
            from artists.models import Artist
            try:
                instance.highlighted_artist = Artist.objects.get(id=highlighted_artist_id)
            except Artist.DoesNotExist:
                pass

        if highlighted_release_id is not None:
            from releases.models import Release
            try:
                instance.highlighted_release = Release.objects.get(id=highlighted_release_id)
            except Release.DoesNotExist:
                pass

        return super().update(instance, validated_data)
