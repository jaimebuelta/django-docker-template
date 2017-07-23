from django.http import JsonResponse
from tweet.models import Tweet

# Create your views here.


def smoketests(request):
    # Check status of each external service
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
