from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import MyLinksViewSet, MyProfileView

router = DefaultRouter()
router.register("links", MyLinksViewSet, basename="my-links")

urlpatterns = [
    path("profile/", MyProfileView.as_view(), name="my-profile"),
    path("", include(router.urls)),
]