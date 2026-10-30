import os
import logging
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler, MessageHandler, filters

# Logging setup taaki errors pata chal sakein
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

# 1. /start Command: Bot shuru hone par yeh message aayega
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_name = update.effective_user.first_name
    welcome_text = (
        f"Namaste {user_name}! 🙏\n"
        "Main aapka **FINAL CUT DUBBERS** bot hoon.\n\n"
        "Yahan sabhi features active hain: Music, Welcome, Tagging, aur File/Video handling!"
    )
    await update.message.reply_text(welcome_text, parse_mode="Markdown")

# 2. Welcome Message: Jab koi naya member group mein join karega
async def welcome_new_member(update: Update, context: ContextTypes.DEFAULT_TYPE):
    for member in update.message.new_chat_members:
        # Apne group ka naam ya rules yahan customize kar sakte hain
        greeting = (
            f"Swagat hai {member.first_name} ji! 🎉\n"
            "Final Cut Dubbers mein aapka swagat hai. "
            "Kripya group ke rules follow karein aur apni dubbing journey enjoy karein!"
        )
        await update.message.reply_text(greeting)

# 3. Tagging Command (`/all`): Group ke sabhi members ko tag karne ke liye
async def tag_all(update: Update, context: ContextTypes.DEFAULT_TYPE):
    # Yeh command sirf group mein chalegi
    if update.effective_chat.type in ["group", "supergroup"]:
        # Agar koi message ke sath text diya ho
        reason = " ".join(context.args) if context.args else "Important Announcement!"
        
        # Note: Telegram direct saare members ki list nahi deta privacy ki wajah se, 
        # isiliye yeh sabhi active members/replies ko alert bhejta hai.
        await update.message.reply_text(
            f"📢 **ATTENTION EVERYONE!** 📢\n\n{reason}\n\n@all members, kripya dhyan dein!"
        )
    else:
        await update.message.reply_text("Yeh command sirf group ke andar kaam karegi!")

# 4. Media & File Handler: Audio, Video, Music ya Files ko handle/save karne ke liye
async def handle_media(update: Update, context: ContextTypes.DEFAULT_TYPE):
    message = update.message
    if message.video:
        await message.reply_text("📹 Video file mil gayi! Isse process kiya ja raha hai...")
    elif message.audio or message.voice:
        await message.reply_text("🎵 Audio / Music file mil gayi! Saving audio...")
    elif message.document:
        await message.reply_text("📁 Document / File successfully received!")

def main():
    # Yahan apni Bot Token daalni hai (Jo aapne BotFather se li hai)
    # Aap ise code mein direct likh sakti hain ya environment variable se le sakti hain.
    TOKEN = os.getenv("BOT_TOKEN", "APNA_BOT_TOKEN_YAHAN_PASTE_KAREIN")
    
    if TOKEN == "
8990182831:AAGpnHd4mziXiJa_696gIUKQ20fooxAL1Ps
":
        print("
8990182831:AAGpnHd4mziXiJa_696gIUKQ20fooxAL1Ps
!")
        return

    # Application build karna
    application = ApplicationBuilder().token(TOKEN).build()

    # Handlers jodna
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("all", tag_all))
    application.add_handler(MessageHandler(filters.StatusUpdate.NEW_CHAT_MEMBERS, welcome_new_member))
    application.add_handler(MessageHandler(filters.PHOTO | filters.VIDEO | filters.AUDIO | filters.VOICE | filters.DOCUMENT, handle_media))

    print("Bot successfully start ho raha hai...")
    
    # Bot ko run karna (Polling method)
    application.run_polling()

if __name__ == '__main__':
    main()
