import os
import requests

HOSTPORT = os.environ.get('SYSTEM_TEST_HOSTPORT')
TWEET_URL = HOSTPORT + 'tweet/'


def test_tweets():
    result = requests.get(TWEET_URL)
    assert result.status_code == 200
    tweets = result.json()
    assert len(tweets) == 2
    for tweet in tweets:
        # Get all the linked urls
        url = tweet['href']
        result = requests.get(url)
        assert result.status_code == 200
