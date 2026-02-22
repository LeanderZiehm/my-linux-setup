from PIL import Image, ImageDraw, ImageFont
import datetime, os

W, H = 3840, 2160
img = Image.new("RGB", (W, H), "black")
draw = ImageDraw.Draw(img)

font = ImageFont.truetype("/usr/share/fonts/TTF/DejaVuSansMono.ttf", 28)
green = (0, 255, 100)

text = f"""
Arch Linux
Kernel: {os.uname().release}
Date: {datetime.datetime.now().strftime('%Y-%m-%d')}
"""

draw.multiline_text((100, 100), text, fill=green, font=font, spacing=10)

img.save("arch_green.png")
