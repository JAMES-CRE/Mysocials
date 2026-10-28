BOT_KEYWORDS = [
    "bot", "crawler", "spider", "crawling",
    "facebookexternalhit", "facebookcatalog",
    "twitterbot", "linkedinbot", "pinterest",
    "whatsapp", "telegrambot", "slackbot",
    "discordbot", "embedly", "quora link preview",
    "showyoubot", "outbrain", "vkShare",
    "w3c_validator", "redditbot", "applebot",
    "skypeuripreview", "nuzzel", "bitlybot",
    "ia_archiver", "googlebot", "bingbot",
    "duckduckbot", "yandex", "baiduspider",
]

BROWSER_HINTS = ["mozilla", "chrome", "safari", "firefox", "edge", "opera"]


def is_bot(request) -> bool:
    ua = (request.META.get("HTTP_USER_AGENT") or "").lower()
    if not ua:
        return True  # no UA = almost certainly a bot
    if any(k in ua for k in BOT_KEYWORDS):
        return True
    # If nothing looks like a browser, treat as bot
    if not any(b in ua for b in BROWSER_HINTS):
        return True
    return False