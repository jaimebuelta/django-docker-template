from django.test import TestCase
from django.core.urlresolvers import reverse
from tweet.models import Tweet


class TweetTest(TestCase):

    def setUp(self):
        self.tweet = Tweet.objects.create(text='Test tweet')
        Tweet.objects.create(text='Another tweet')

    def test_list_tweets(self):
        url = reverse('list_tweets')
        response = self.client.get(url)
        assert response.status_code == 200
        result = response.json()
        assert len(result) == 2

        # Walk throught the results
        for tweet in result:
            response = self.client.get(tweet['href'])
            assert response.status_code == 200

    def test_single_tweet(self):
        url = reverse('get_tweet', kwargs={'pk': self.tweet.id})
        response = self.client.get(url)
        assert response.status_code == 200

        # Check structure
        result = response.json()
        assert set(result.keys()) == {'text', 'href', 'timestamp'}
        assert result['text'] == 'Test tweet'
        assert url in result['href']

    def test_bad_tweet(self):
        url = reverse('get_tweet', kwargs={'pk': 12345})
        response = self.client.get(url)
        assert response.status_code == 404
