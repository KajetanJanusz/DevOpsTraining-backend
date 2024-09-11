from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from backend import settings

@api_view(['GET'])
def healthcheck(request):
    auth_header = request.headers.get('Authorization')

    try:
        token_type, token = auth_header.split(' ')
    except (ValueError, AttributeError):
        return Response({'error': 'Invalid Authorization header format'}, status=status.HTTP_400_BAD_REQUEST)

    if not token:
        return Response({'error': 'There is no token header inside request'}, status=status.HTTP_400_BAD_REQUEST)

    if token != settings.HEALTH_CHECK_TOKEN:
        return Response({'error': 'There is no token header inside request'}, status=status.HTTP_400_BAD_REQUEST)

    return Response({'status': 'ok'}, status=status.HTTP_200_OK)