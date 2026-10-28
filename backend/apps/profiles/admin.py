from django.contrib import admin
from .models import Profile, SocialLink


class SocialLinkInline(admin.TabularInline):
    model = SocialLink
    extra = 0
    fields = ("platform", "url", "label", "order", "is_active")
    ordering = ("order",)


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "display_name", "updated_at")
    search_fields = ("user__username", "user__email", "display_name")
    inlines = [SocialLinkInline]


@admin.register(SocialLink)
class SocialLinkAdmin(admin.ModelAdmin):
    list_display = ("profile", "platform", "url", "order", "is_active")
    list_filter = ("platform", "is_active")
    search_fields = ("profile__user__username", "url", "label")