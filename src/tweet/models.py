from django.db import models


# Create your models here.
class Tweet(models.Model):
    text = models.CharField(max_length=140)
    timestamp = models.DateTimeField(auto_now_add=True)
