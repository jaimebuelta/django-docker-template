from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.TweetListView.as_view(), name='list_tweets'),
    url(r'^(?P<pk>\d+)$', views.TweetView.as_view(), name='get_tweet'),
]
