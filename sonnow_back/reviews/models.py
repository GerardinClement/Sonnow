from django.contrib.auth.models import User
from django.db import models

class Review(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    release_id = models.CharField(max_length=100)
    content = models.TextField()
    rating = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)