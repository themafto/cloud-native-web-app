# /backend_redis/core/views.py

import redis
from django.http import JsonResponse
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

def index(request):
    return render(request, 'index.html')

def test_connection(request):
    try:
        # Create a Redis client using settings
        r = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            db=settings.REDIS_DB,
            password=settings.REDIS_PASSWORD
        )
        # Ping the Redis server
        r.ping()
        return JsonResponse({'message': 'Connection to Backend Redis is successful!'})
    except redis.RedisError as e:
        logger.error(f"Error connecting to Redis: {e}")
        return JsonResponse({'error': str(e)}, status=500)
