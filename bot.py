import os, subprocess, logging
from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, ContextTypes, filters
from config import BOT_TOKEN, DOWNLOAD_DIR

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def on_video(update: Update, context: ContextTypes.DEFAULT_TYPE):
    msg = update.message

    # 1) Download to local file
    vid = await context.bot.get_file(msg.video.file_id)
    mp4 = os.path.join(DOWNLOAD_DIR, f"{msg.video.file_id}.mp4")
    await vid.download_to_drive(mp4)
    await msg.reply_text("✅ Downloaded. Extracting subtitles…")
    logger.info(f"Saved video to {mp4}")

    # 2) Invoke HINO
    srt = mp4 + ".srt"
    hino_bin = os.path.join(os.getcwd(), "hino", "HardsubIsNotOk")
    subprocess.run([hino_bin, "-i", mp4, "-o", srt], check=True)
    logger.info(f"HINO wrote {srt}")

    # 3) Send SRT back
    await msg.reply_document(open(srt, "rb"), filename="subtitles.srt")
    logger.info("Subtitle file sent.")

def main():
    app = ApplicationBuilder().token(BOT_TOKEN).build()
    app.add_handler(MessageHandler(filters.VIDEO, on_video))
    app.run_polling(drop_pending_updates=True)

if __name__ == "__main__":
    main()
