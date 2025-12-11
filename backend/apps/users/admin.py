from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('nom', 'age', 'centres_interet', 'role', 'date_creation')}),
    )

admin.site.register(CustomUser, CustomUserAdmin)
