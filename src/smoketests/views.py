from django.http import JsonResponse
from tweet.models import Tweet


def smoketests(request):
    '''
    Check status of each external service.
    Remember to keep everything lightweight and add short timeouts
    '''
    result = {'status': 'ok'}

    # Check DB making a lightweight DB query
    try:
        Tweet.objects.first()
        result['db'] = {'status': 'ok'}
    except Exception as err:
        result['status'] = 'nok'
        result['db'] = {
            'status': 'nok',
            'err_msg': 'Error accessing DB: {}'.format(err),
        }

    status_code = 200
    if result['status'] != 'ok':
        status_code = 500

    response = JsonResponse(result)
    response.status_code = status_code
    return response
