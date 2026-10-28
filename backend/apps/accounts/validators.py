import re
from django.core.exceptions import ValidationError

RESERVED_USERNAMES = {
    "admin", "api", "auth", "login", "logout", "register", "signup",
    "me", "u", "user", "users", "settings", "dashboard", "profile",
    "profiles", "link", "links", "help", "support", "about", "terms",
    "privacy", "static", "media", "assets", "public", "private",
    "docs", "swagger", "schema", "root", "system", "mysocials",
    "www", "mail", "ftp", "ns1", "ns2", "cdn", "app", "apps",
}

USERNAME_REGEX = re.compile(r"^[a-z0-9](?:[a-z0-9_.-]{1,28}[a-z0-9])?$")


def validate_username(value: str):
    value = value.strip().lower()

    if len(value) < 3:
        raise ValidationError("Username must be at least 3 characters.")
    if len(value) > 30:
        raise ValidationError("Username must be at most 30 characters.")
    if not USERNAME_REGEX.match(value):
        raise ValidationError(
            "Username must start and end with a letter or number, "
            "and may only contain a-z, 0-9, _, ., -."
        )
    if value in RESERVED_USERNAMES:
        raise ValidationError("That username is reserved.")
    return value