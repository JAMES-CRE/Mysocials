from django.shortcuts import get_object_or_404
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Profile, SocialLink
from .serializers import (
    ProfileSerializer,
    PublicProfileSerializer,
    ReorderSerializer,
    SocialLinkSerializer,
)


class MyProfileView(APIView):
    """GET / PATCH the authenticated user's profile."""
    permission_classes = [permissions.IsAuthenticated]

    def _get_profile(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        return profile

    def get(self, request):
        profile = self._get_profile(request)
        return Response(ProfileSerializer(profile, context={"request": request}).data)

    def patch(self, request):
        profile = self._get_profile(request)
        serializer = ProfileSerializer(
            profile,
            data=request.data,
            partial=True,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class MyLinksViewSet(viewsets.ModelViewSet):
    """CRUD for the authenticated user's social links."""
    serializer_class = SocialLinkSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        return SocialLink.objects.filter(profile__user=self.request.user)

    def perform_create(self, serializer):
        profile, _ = Profile.objects.get_or_create(user=self.request.user)
        # Auto-assign order = last position
        last = profile.links.order_by("-order").first()
        next_order = (last.order + 1) if last else 0
        serializer.save(profile=profile, order=serializer.validated_data.get("order", next_order))

    @action(detail=False, methods=["post"], url_path="reorder")
    def reorder(self, request):
        serializer = ReorderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        ids = [item["id"] for item in serializer.validated_data["items"]]
        links = {link.id: link for link in self.get_queryset().filter(id__in=ids)}

        updated = []
        for item in serializer.validated_data["items"]:
            link = links.get(item["id"])
            if link:
                link.order = item["order"]
                updated.append(link)
        SocialLink.objects.bulk_update(updated, ["order"])
        return Response({"updated": len(updated)})


class PublicProfileView(APIView):
    """GET /api/u/<username>/ — no auth, returns public data."""
    permission_classes = [permissions.AllowAny]

    def get(self, request, username):
        profile = get_object_or_404(
            Profile.objects.select_related("user").prefetch_related("links"),
            user__username__iexact=username,
        )
        data = PublicProfileSerializer(profile, context={"request": request}).data
        return Response(data)