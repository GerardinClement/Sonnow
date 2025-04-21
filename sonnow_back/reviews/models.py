from django.contrib.auth.models import User
from django.db import models
from releases.models import Release


class ReactionType(models.Model):
    emoji = models.CharField(max_length=20)
    name = models.CharField(max_length=50)

    def __str__(self):
        return f"{self.emoji} - {self.name}"

class ReactionReview(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    review = models.ForeignKey('Review', on_delete=models.CASCADE)
    #reaction_type = models.ForeignKey(ReactionType, on_delete=models.CASCADE)
    emoji = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'review', 'emoji')

class Tag(models.Model):
    content = models.CharField(max_length=20, unique=True)

class Review(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    release = models.ForeignKey(Release, on_delete=models.CASCADE)
    content = models.TextField()
    tags = models.ManyToManyField(Tag, related_name='reviews')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def reactions(self):
        return ReactionReview.objects.filter(review=self)

    class Meta:
        unique_together = ('user', 'release')
        ordering = ['-created_at']

