from rest_framework import generics, permissions, status
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.profiles.models import Profile
from .serializers import RegisterSerializer, UserSerializer


class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class MeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class AvatarUploadView(APIView):
    """POST /api/auth/me/avatar/  (multipart/form-data, field: avatar)"""
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    MAX_BYTES = 3 * 1024 * 1024  # 3 MB
    ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}

    def post(self, request):
        file = request.FILES.get("avatar")
        if not file:
            return Response({"detail": "No file provided. Use field name 'avatar'."},
                            status=status.HTTP_400_BAD_REQUEST)

        if file.size > self.MAX_BYTES:
            return Response({"detail": "File too large (max 3 MB)."},
                            status=status.HTTP_400_BAD_REQUEST)

        if file.content_type not in self.ALLOWED_TYPES:
            return Response({"detail": "Only JPEG, PNG, or WebP allowed."},
                            status=status.HTTP_400_BAD_REQUEST)

        profile, _ = Profile.objects.get_or_create(user=request.user)

        # Delete old avatar to avoid orphan files
        if profile.avatar:
            profile.avatar.delete(save=False)

        profile.avatar = file
        profile.save(update_fields=["avatar", "updated_at"])

        from apps.profiles.serializers import ProfileSerializer
        return Response(
            ProfileSerializer(profile, context={"request": request}).data,
            status=status.HTTP_200_OK,
        )