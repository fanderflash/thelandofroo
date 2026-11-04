from PIL import Image, ImageDraw, ImageFont, ImageOps
from pathlib import Path
import subprocess, math, json

P=Path(__file__).parent
G=P.parent/'generated_images'
font_path=P/'font.ttf'
if not font_path.exists():font_path=P.parent/'fonts/CormorantGaramond-SemiBold.ttf'
font=lambda n:ImageFont.truetype(str(font_path),n)
sources={'11-giant-step-source.jpg':'exec-281d4a82-6a45-4b1c-a80f-f98c4841b6f9.png','17-cloak-before-source.jpg':'exec-76451b8e-e85a-451a-b7bf-abed881e9363.png','17-cloak-after-source.jpg':'exec-4780f286-0929-4a6b-af9f-f231288dbece.png'}
for dst,src in sources.items():
    if not (P/dst).exists():Image.open(G/src).convert('RGB').save(P/dst,quality=97,subsampling=0)

def drawtext(img,lines,ys,size,alpha=255):
    layer=Image.new('RGBA',img.size)
    d=ImageDraw.Draw(layer)
    for text,y in zip(lines,ys):
        d.text((img.width/2,y),text,font=font(size),anchor='mt',fill=(255,246,226,alpha),stroke_width=2,stroke_fill=(17,20,18,round(alpha*.8)))
    return Image.alpha_composite(img.convert('RGBA'),layer).convert('RGB')

for i,(src,head,foot) in enumerate([
    ('17-cloak-before-source.jpg','Would you throw it away?','Swipe to see what she saved.'),
    ('17-cloak-after-source.jpg','One patch. Another journey.','What have you kept by repairing it?')],1):
    im=ImageOps.fit(Image.open(P/src),(1080,1350),method=Image.Resampling.LANCZOS)
    overlay=Image.new('RGBA',im.size);d=ImageDraw.Draw(overlay)
    for y in range(170):d.line((0,y,1080,y),fill=(8,15,13,round(100*(1-y/170))))
    for y in range(1170,1350):d.line((0,y,1080,y),fill=(8,15,13,round(135*(y-1170)/180)))
    im=Image.alpha_composite(im.convert('RGBA'),overlay)
    im=drawtext(im,[head],[43],73)
    im=drawtext(im,[foot],[1240],47)
    im.save(P/f'17-cloak-{i:02}.jpg',quality=94,subsampling=0)

src=ImageOps.fit(Image.open(P/'11-giant-step-source.jpg').convert('RGB'),(1080,1920),method=Image.Resampling.LANCZOS)
def ease(x):
    x=max(0,min(1,x));return x*x*(3-2*x)
cmd=['ffmpeg','-hide_banner','-loglevel','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s','1080x1920','-r','30','-i','-','-f','lavfi','-i','anullsrc=channel_layout=stereo:sample_rate=48000','-t','14','-c:v','libx264','-preset','medium','-crf','23','-pix_fmt','yuv420p','-r','30','-c:a','aac','-b:a','96k','-movflags','+faststart',str(P/'11-giant-step-reel.mp4')]
p=subprocess.Popen(cmd,stdin=subprocess.PIPE)
for n in range(420):
    t=n/30;z=1+.09*ease(n/419)
    cw,ch=1080/z,1920/z
    x,y=(1080-cw)*.44,(1920-ch)*.44
    im=src.transform((1080,1920),Image.Transform.EXTENT,(x,y,x+cw,y+ch),resample=Image.Resampling.BICUBIC)
    im=drawtext(im,["These stairs weren't",'built for us.'],[160,270],91,round(255*ease((t-.2)/1.55)))
    im=drawtext(im,['Who would you bring?'],[1470],64,round(255*ease((t-7)/1.5)))
    p.stdin.write(im.tobytes())
p.stdin.close()
assert p.wait()==0
print('Rendered original 14-second, 9-percent eased single-scene Reel and two-frame carousel.',flush=True)
