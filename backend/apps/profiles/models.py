from django.conf import settings
from django.db import models


class Platform(models.TextChoices):
    TWITTER = "twitter", "Twitter / X"
    INSTAGRAM = "instagram", "Instagram"
    FACEBOOK = "facebook", "Facebook"
    TIKTOK = "tiktok", "TikTok"
    LINKEDIN = "linkedin", "LinkedIn"
    YOUTUBE = "youtube", "YouTube"
    GITHUB = "github", "GitHub"
    WHATSAPP = "whatsapp", "WhatsApp"
    TELEGRAM = "telegram", "Telegram"
    SNAPCHAT = "snapchat", "Snapchat"
    THREADS = "threads", "Threads"
    EMAIL = "email", "Email"
    WEBSITE = "website", "Website"
    OTHER = "other", "Other"


class Profile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="profile",
    )
    display_name = models.CharField(max_length=80, blank=True)
    bio = models.CharField(max_length=280, blank=True)
    avatar = models.ImageField(upload_to="avatars/", blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Profile({self.user.username})"


class SocialLink(models.Model):
    profile = models.ForeignKey(
        Profile,
        on_delete=models.CASCADE,
        related_name="links",
    )
    platform = models.CharField(max_length=20, choices=Platform.choices)
    url = models.URLField(max_length=500)
    label = models.CharField(max_length=60, blank=True)
    order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["order", "id"]

    def __str__(self):
        return f"{self.platform} → {self.url}"