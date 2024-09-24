from .models import CustomUser
from rest_framework.serializers import ModelSerializer

class CreateUserSerializer(ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['username', 'password', 'age']