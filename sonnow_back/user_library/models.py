from django.contrib.auth.models import User
from django.db import models

class LikedRelease(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    release = models.ForeignKey('releases.Release', on_delete=models.CASCADE)
    date_added = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'release',)

class LikedArtist(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    artist = models.ForeignKey('artists.Artist', on_delete=models.CASCADE)
    date_added = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'artist',)

class ToListenRelease(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    release = models.ForeignKey('releases.Release', on_delete=models.CASCADE)
    date_added = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'release',)