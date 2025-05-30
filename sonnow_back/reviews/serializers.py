from rest_framework.serializers import ModelSerializer
from rest_framework import serializers

from releases.models import Release
from .models import Review, Tag, ReactionReview, ReactionType
from user_profile.models import Profile

class SimpleProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    profile_picture = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = ['id', 'username', 'display_name', 'profile_picture']

    def get_profile_picture(self, obj):
        if obj.profile_picture:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_picture.url)
            return obj.profile_picture.url
        return None

class ReactionTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReactionType
        fields = ['id', 'name', 'emoji']

class ReactionReviewSerializer(serializers.ModelSerializer):
    user = SimpleProfileSerializer(source='user.profile', read_only=True)

    class Meta:
        model = ReactionReview
        fields = ['id', 'user', 'review', 'emoji']
        read_only_fields = ['user', 'review']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

class TagSerializer(ModelSerializer):
    class Meta:
        model = Tag
        fields = ['id', 'content']

class SimpleReleaseSerializer(serializers.ModelSerializer):
    artist = serializers.SerializerMethodField()

    class Meta:
        model = Release
        fields = ['id', 'title', 'image_url', 'release_date', 'artist']

    def get_artist(self, obj):
        from artists.serializers import ArtistSerializer
        return ArtistSerializer(obj.artist, read_only=True, context=self.context).data

class ReviewSerializer(ModelSerializer):
    release = SimpleReleaseSerializer(read_only=True)
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
    user_profile = SimpleProfileSerializer(source='user.profile', read_only=True)
    reactions = ReactionReviewSerializer(many=True, read_only=True)

    class Meta:
        model = Review
        fields = ['id', 'user', 'user_profile','release', 'release_id', 'tags', 'tag_ids', 'content', 'created_at', 'updated_at', 'reactions']
        read_only_fields = ['user', 'created_at', 'updated_at', 'reactions']

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