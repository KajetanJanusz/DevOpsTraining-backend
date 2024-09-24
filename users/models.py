from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MaxValueValidator

class CustomUser(AbstractUser):
    age = models.PositiveIntegerField(
        validators=[MaxValueValidator(100, 'Input your real age.')]
    )