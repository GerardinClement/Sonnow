from rest_framework import serializers
from artists.serializers import ArtistSerializer
from .models import Release
from artists.models import Artist

class ReleaseSerializer(serializers.ModelSerializer):
    artist = ArtistSerializer(read_only=True)
    artist_id = serializers.IntegerField(write_only=True, required=False)

    class Meta:
        model = Release
        fields = [
            'id',
            'title',
            'artist',
            'artist_id',
            'release_date',
            'image_url',
            'type',
        ]
        read_only_fields = ['artist']

    def create(self, validated_data):
        artist_id = validated_data.pop('artist_id', None)
        if artist_id:
            try:
                validated_data['artist'] = Artist.objects.get(id=artist_id)
            except Artist.DoesNotExist:
                raise serializers.ValidationError("Artist with this ID does not exist.")
        return super().create(validated_data)
