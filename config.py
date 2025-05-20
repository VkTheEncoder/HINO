import os
BOT_TOKEN    = os.getenv("TELEGRAM_BOT_TOKEN", "8096088012:AAEC0AQzB0TDhXZ0IBoXUsZn4k_uQDJSiDM")
DOWNLOAD_DIR = "downloads"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)
