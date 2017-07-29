from django.core.urlresolvers import reverse
from django.test import TestCase
from unittest import mock


class HealthCheck(TestCase):

    def test_good_healthcheck(self):
        url = reverse('healthcheck')
        response = self.client.get(url)
        assert response.status_code == 200

        # Check structure
        result = response.json()
        assert result == {'status': 'ok', 'db': {'status': 'ok'}}

    @mock.patch('tweet.models.Tweet.objects.first')
    def test_bad_healthcheck(self, db_mock):
        db_mock.side_effect = Exception('This is an error')

        url = reverse('healthcheck')
        response = self.client.get(url)
        assert response.status_code == 500

        # Check structure
        result = response.json()
        expected_result = {
            'status': 'nok',
            'db': {
                'status': 'nok',
                'err_msg': 'Error accessing DB: This is an error',
            },
        }
        assert result == expected_result
