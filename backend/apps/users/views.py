from django.contrib.auth import get_user_model, authenticate
from rest_framework import generics, permissions, viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .serializers import RegisterSerializer, UserSerializer

User = get_user_model()


# 🟢 Registration view
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


# 🟢 Custom serializer to add extra user info to JWT token
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)

        # Add custom claims
        token["username"] = user.username
        token["email"] = user.email
        token["role"] = getattr(user, "role", None)

        return token


# 🟢 Login view
class LoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        username = request.data.get("username")
        password = request.data.get("password")

        user = authenticate(username=username, password=password)
        if user:
            refresh = RefreshToken.for_user(user)
            return Response({
                "refresh": str(refresh),
                "access": str(refresh.access_token),
                "user": UserSerializer(user).data
            })

        return Response({"error": "Invalid credentials"}, status=400)


# 🟢 User viewset (read-only)
class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]


# 🟢 Profile endpoint (for authenticated users only)

# 🟢 Profile endpoint (GET and PATCH/PUT for updates)
class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user
    
    def update(self, request, *args, **kwargs):
        """Handle profile updates"""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        
        return Response(serializer.data)
    
    def partial_update(self, request, *args, **kwargs):
        """Handle PATCH requests for partial updates"""
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)

"""  
class ProfileView(generics.RetrieveUpdateAPIView):  # Changed from RetrieveAPIView
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user
"""


# 🆕 NEW: Get user's created astuces
class UserAstucesView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Return astuces created by the current user"""
        # Import here to avoid circular imports
        from apps.astuces.models import Astuce
        return Astuce.objects.filter(createur=self.request.user).order_by('-date_publication')
    
    def get_serializer_class(self):
        """Dynamically import serializer to avoid circular imports"""
        from apps.astuces.serializers import AstuceSerializer
        return AstuceSerializer


# 🆕 NEW: Get user's evaluations
class UserEvaluationsView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Return evaluations written by the current user"""
        # Import here to avoid circular imports
        from apps.astuces.models import Evaluation
        return Evaluation.objects.filter(utilisateur=self.request.user).select_related('astuce').order_by('-date')
    
    def get_serializer_class(self):
        """Dynamically import serializer to avoid circular imports"""
        from apps.astuces.serializers import EvaluationSerializer
        return EvaluationSerializer


# 🆕 NEW: Get user's propositions
class UserPropositionsView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Return propositions created by the current user"""
        # Import here to avoid circular imports
        from apps.astuces.models import Proposition
        return Proposition.objects.filter(utilisateur=self.request.user).order_by('-date')
    
    def get_serializer_class(self):
        """Dynamically import serializer to avoid circular imports"""
        from apps.astuces.serializers import PropositionSerializer
        return PropositionSerializer


# 🆕 NEW: Change Password view
class ChangePasswordView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        """
        Change the password for the authenticated user.
        Expects:
        {
            "current_password": "old_password",
            "new_password": "new_password"
        }
        """
        user = request.user
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')
        
        # Validate inputs
        if not current_password or not new_password:
            return Response(
                {'error': 'current_password and new_password are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if current password is correct
        if not user.check_password(current_password):
            return Response(
                {'error': 'Current password is incorrect'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if new password is same as old
        if current_password == new_password:
            return Response(
                {'error': 'New password must be different from current password'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Set new password
        user.set_password(new_password)
        user.save()
        
        return Response(
            {'success': True, 'message': 'Password changed successfully'},
            status=status.HTTP_200_OK
        )


# 🆕 NEW: Forgot Password view
class ForgotPasswordView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request, *args, **kwargs):
        """
        Request password reset. Sends reset link to email.
        Expects:
        {
            "email": "user@example.com"
        }
        """
        email = request.data.get('email')
        
        if not email:
            return Response(
                {'error': 'Email is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Find user by email
            user = User.objects.get(email=email)
            
            # Generate a simple token (in production, use proper token generation)
            from django.utils.crypto import get_random_string
            reset_token = get_random_string(32)
            
            # Save token to user (in production, use a separate model with expiration)
            user.profile.reset_token = reset_token
            user.profile.save()
            
            # In production: send email with reset link
            # For now, return token in response (NOT secure, for testing only)
            print(f"✅ Password reset token for {email}: {reset_token}")
            
            return Response(
                {'success': True, 'message': 'Password reset link sent to email'},
                status=status.HTTP_200_OK
            )
        except User.DoesNotExist:
            # Don't reveal if email exists (security best practice)
            return Response(
                {'success': True, 'message': 'If email exists, reset link will be sent'},
                status=status.HTTP_200_OK
            )


# 🆕 NEW: Reset Password view
class ResetPasswordView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request, *args, **kwargs):
        """
        Reset password using token.
        Expects:
        {
            "email": "user@example.com",
            "token": "reset_token",
            "new_password": "new_password"
        }
        """
        email = request.data.get('email')
        token = request.data.get('token')
        new_password = request.data.get('new_password')
        
        if not all([email, token, new_password]):
            return Response(
                {'error': 'Email, token and new_password are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(email=email)
            
            # Verify token
            if user.profile.reset_token != token:
                return Response(
                    {'error': 'Invalid or expired token'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Set new password
            user.set_password(new_password)
            user.save()
            
            # Clear token
            user.profile.reset_token = None
            user.profile.save()
            
            return Response(
                {'success': True, 'message': 'Password reset successfully'},
                status=status.HTTP_200_OK
            )
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found'},
                status=status.HTTP_404_NOT_FOUND
            )