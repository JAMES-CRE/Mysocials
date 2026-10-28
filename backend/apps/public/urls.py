from django.urls import path
from .views import PublicProfileAPI, public_profile_page

urlpatterns = [
    path("u/<str:username>/", PublicProfileAPI.as_view(), name="public-profile-api"),
    path("<str:username>/", public_profile_page, name="public-profile-page"),
]