from django.contrib.auth import get_user_model
from rest_framework import serializers

from .models import Profile, SocialLink

User = get_user_model()


class SocialLinkSerializer(serializers.ModelSerializer):
    platform_display = serializers.CharField(source="get_platform_display", read_only=True)

    class Meta:
        model = SocialLink
        fields = (
            "id",
            "platform",
            "platform_display",
            "url",
            "label",
            "order",
            "is_active",
            "created_at",
        )
        read_only_fields = ("id", "created_at")


class ProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source="user.username", read_only=True)
    email = serializers.EmailField(source="user.email", read_only=True)
    avatar_url = serializers.SerializerMethodField()
    links = SocialLinkSerializer(many=True, read_only=True)

    class Meta:
        model = Profile
        fields = (
            "id",
            "username",
            "email",
            "display_name",
            "bio",
            "avatar",
            "avatar_url",
            "links",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("id", "created_at", "updated_at", "links")
        extra_kwargs = {"avatar": {"write_only": True}}

    def get_avatar_url(self, obj):
        if not obj.avatar:
            return None
        request = self.context.get("request")
        url = obj.avatar.url
        return request.build_absolute_uri(url) if request else url

    def validate_avatar(self, value):
        if value is None:
            return value
        if value.size > 3 * 1024 * 1024:
            raise serializers.ValidationError("Avatar must be under 3 MB.")
        if value.content_type not in {"image/jpeg", "image/png", "image/webp"}:
            raise serializers.ValidationError("Avatar must be JPEG, PNG, or WebP.")
        return value

class PublicProfileSerializer(serializers.ModelSerializer):
    """Public view: no email, only active links."""
    username = serializers.CharField(source="user.username", read_only=True)
    avatar_url = serializers.SerializerMethodField()
    links = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = ("username", "display_name", "bio", "avatar_url", "links")

    def get_avatar_url(self, obj):
        if not obj.avatar:
            return None
        request = self.context.get("request")
        url = obj.avatar.url
        return request.build_absolute_uri(url) if request else url

    def get_links(self, obj):
        active = obj.links.filter(is_active=True).order_by("order", "id")
        return SocialLinkSerializer(active, many=True).data


class ReorderItemSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    order = serializers.IntegerField(min_value=0)


class ReorderSerializer(serializers.Serializer):
    items = ReorderItemSerializer(many=True)