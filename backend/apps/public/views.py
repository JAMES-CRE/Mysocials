from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, render
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.profiles.models import Profile
from apps.profiles.serializers import PublicProfileSerializer

from .bot_detector import is_bot


def _get_profile_or_404(username: str) -> Profile:
    return get_object_or_404(
        Profile.objects.select_related("user").prefetch_related("links"),
        user__username__iexact=username,
    )


class PublicProfileAPI(APIView):
    """GET /api/u/<username>/ — JSON for the Flutter app."""
    permission_classes = [permissions.AllowAny]

    def get(self, request, username):
        profile = _get_profile_or_404(username)
        data = PublicProfileSerializer(profile, context={"request": request}).data
        return Response(data)


def public_profile_page(request, username):
    """
    GET /<username> — HTML for bots (SEO/social previews),
    Flutter app for humans.
    """
    profile = _get_profile_or_404(username)
    data = PublicProfileSerializer(profile, context={"request": request}).data

    if is_bot(request):
        return render(request, "public_profile.html", {
            "profile": profile,
            "data": data,
            "page_url": request.build_absolute_uri(),
            "site_name": "MySocials",
        })

    # Humans → serve Flutter web's index.html (Phase 6 will replace this).
    # For now, return a tiny bridge page that redirects to the Flutter app URL.
    flutter_app_url = getattr(settings, "FLUTTER_APP_URL", "")
    if flutter_app_url:
        redirect_url = f"{flutter_app_url.rstrip('/')}/u/{profile.user.username}"
        html = f"""<!doctype html>
<html><head>
<meta charset="utf-8">
<title>Redirecting…</title>
<meta http-equiv="refresh" content="0;url={redirect_url}">
<script>window.location.replace("{redirect_url}");</script>
</head><body>Opening MySocials…</body></html>"""
        return HttpResponse(html)

    # No Flutter URL configured yet → show HTML for everyone
    return render(request, "public_profile.html", {
        "profile": profile,
        "data": data,
        "page_url": request.build_absolute_uri(),
        "site_name": "MySocials",
    })