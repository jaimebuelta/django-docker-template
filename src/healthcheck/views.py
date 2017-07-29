from django.http import JsonResponse
from tweet.models import Tweet
import logging

# Set templatesite as top level to use the proper logger
logger = logging.getLogger('templatesite.{}'.format(__name__))


def healthcheck(request):
    '''
    Check status of each external service.
    Remember to keep everything lightweight and add short timeouts
    '''
    result = {'status': 'ok'}
    logger.info('Performing healthcheck')

    # Check DB making a lightweight DB query
    try:
        Tweet.objects.first()
        result['db'] = {'status': 'ok'}
    except Exception as err:
        result['status'] = 'nok'
        err_msg = 'Error accessing DB: {}'.format(err)
        result['db'] = {
            'status': 'nok',
            'err_msg': err_msg,
        }
        logger.error(err_msg)

    logger.debug('Healtchcheck result {}'.format(result))

    status_code = 200
    if result['status'] != 'ok':
        logger.error('Healthcheck result is bad')
        status_code = 500
    else:
        logger.info('Healtchcheck result is ok')

    response = JsonResponse(result)
    response.status_code = status_code
    return response
