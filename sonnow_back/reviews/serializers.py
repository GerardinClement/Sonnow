from rest_framework.serializers import ModelSerializer
from rest_framework import serializers

from releases.models import Release
from releases.serializers import ReleaseSerializer
from user_profile.serializers import ProfileSerializer
from .models import Review, Tag

class TagSerializer(ModelSerializer):
    class Meta:
        model = Tag
        fields = ['id', 'content']

class ReviewSerializer(ModelSerializer):
    release = ReleaseSerializer(read_only=True)
    release_id = serializers.PrimaryKeyRelatedField(
        queryset=Release.objects.all(),
        write_only=True
    )
    tags = TagSerializer(many=True, read_only=True)
    tag_ids = serializers.PrimaryKeyRelatedField(
        queryset=Tag.objects.all(),
        many=True,
        required=True,
        write_only=True
    )
    user_profile = ProfileSerializer(source='user.profile', read_only=True)

    class Meta:
        model = Review
        fields = ['id', 'user', 'user_profile','release', 'release_id', 'tags', 'tag_ids', 'content', 'created_at', 'updated_at']
        read_only_fields = ['user', 'created_at', 'updated_at']

    def create(self, validated_data):
        tags = validated_data.pop('tag_ids', [])
        release = validated_data.pop('release_id')
        validated_data['user'] = self.context['request'].user
        validated_data['release'] = release
        review = Review.objects.create(**validated_data)
        review.tags.set(tags)
        return review

    def validate(self, data):
        user = self.context['request'].user
        release = data.get('release_id')

        if Review.objects.filter(user=user, release=release).exists():
            raise serializers.ValidationError("You have already reviewed this release.")

        return data
