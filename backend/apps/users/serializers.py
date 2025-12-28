from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    avatar_url = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['id', 'username', 'nom', 'email', 'age', 'centres_interet', 'role', 'date_creation','bio', 'phone', 'avatar', 'avatar_url']
    
    def get_avatar_url(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                url = request.build_absolute_uri(obj.avatar.url)
                print(f"👤 User {obj.username} avatar_url: {url}")
                return url
            # Fallback: construire l'URL absolue même sans request
            avatar_path = str(obj.avatar)
            if avatar_path.startswith('media/'):
                return f"http://192.168.137.1:8000/{avatar_path}"
            else:
                return f"http://192.168.137.1:8000/media/{avatar_path}"
        return None

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'nom', 'age', 'centres_interet', 'avatar']

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

