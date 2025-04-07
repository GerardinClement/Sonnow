from rest_framework import serializers
from .models import Artist

class ArtistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Artist
        fields =  '__all__'


    def create(self, validated_data):
        # Custom logic for creating an artist can be added here
        artist_id = validated_data.pop('artist_id', None)
        return super().create(validated_data)