from django.shortcuts import render
from tweet.models import Tweet
from rest_framework.generics import RetrieveAPIView, ListCreateAPIView
from rest_framework import serializers


# Create your views here.
class TweetSerializer(serializers.HyperlinkedModelSerializer):
    href = serializers.HyperlinkedIdentityField(view_name='get_tweet')

    class Meta:
        model = Tweet
        fields = ('text', 'timestamp', 'href')


class TweetView(RetrieveAPIView):
    queryset = Tweet.objects.all()
    serializer_class = TweetSerializer


class TweetListView(ListCreateAPIView):
    queryset = Tweet.objects.all()
    serializer_class = TweetSerializer
