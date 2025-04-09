from django.contrib.auth.models import User
from django.db import models
from releases.models import Release

class Tag(models.Model):
    content = models.CharField(max_length=20, unique=True)

class Review(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    release = models.ForeignKey(Release, on_delete=models.CASCADE)
    content = models.TextField()
    tags = models.ManyToManyField(Tag, related_name='reviews')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'release')
        ordering = ['-created_at']

