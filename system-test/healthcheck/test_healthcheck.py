import os
import requests

HOSTPORT = os.environ.get('SYSTEM_TEST_HOSTPORT')
HEALTHCHECK_URL = HOSTPORT + 'healthcheck'


def test_healthcheck():
    response = requests.get(HEALTHCHECK_URL)
    assert response.status_code == 200


def test_request_id():
    ''' Ensure the request id is returned '''
    response = requests.get(HEALTHCHECK_URL)
    assert response.status_code == 200
    assert 'X-REQUEST-ID' in response.headers


def test_external_request_id():
    ''' Ensure the request id returned s the same as set up'''
    headers = {
        'X-REQUEST-ID': 'test_id',
    }
    response = requests.get(HEALTHCHECK_URL, headers=headers)
    assert response.status_code == 200
    assert 'X-REQUEST-ID' in response.headers
    assert response.headers['X-REQUEST-ID'] == 'test_id'
