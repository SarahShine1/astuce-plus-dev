from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'nom', 'email', 'age', 'centres_interet', 'role', 'date_creation']

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'nom', 'age', 'centres_interet']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', None),
            password=validated_data['password'],
            nom=validated_data.get('nom', ''),
            age=validated_data.get('age', None),
            centres_interet=validated_data.get('centres_interet', ''),
        )
        return user

