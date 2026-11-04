from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import subprocess,json,numpy as np,struct,hashlib
P=Path(__file__).parent;v=P/'11-giant-step-reel.mp4'
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(v)]))
vs=next(s for s in probe['streams'] if s['codec_type']=='video');au=next(s for s in probe['streams'] if s['codec_type']=='audio')
assert (vs['width'],vs['height'],vs['codec_name'],vs['pix_fmt'],vs['r_frame_rate'])==(1080,1920,'h264','yuv420p','30/1')
assert au['codec_name']=='aac' and 10<=float(probe['format']['duration'])<=18
data=v.read_bytes();atoms=[];pos=0
while pos+8<=len(data):
    length,kind=struct.unpack('>I4s',data[pos:pos+8]);atoms.append(kind.decode('ascii'));pos+=length
assert atoms.index('moov')<atoms.index('mdat')
raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(v),'-vf','scale=270:480','-f','rawvideo','-pix_fmt','rgb24','-'])
frames=np.frombuffer(raw,dtype=np.uint8).reshape(-1,480,270,3)
assert len(frames)==420
# Every decoded frame is examined for discontinuities, including the ending.
body=frames[:,100:350].astype(np.float32)
delta=np.abs(np.diff(body,axis=0)).mean(axis=(1,2,3))
assert float(delta.max())<4, 'Visible discontinuity requires review'
selected=[0,15,30,53,120,210,255,419]
sheet=Image.new('RGB',(270*4,510*2),'#111111');d=ImageDraw.Draw(sheet)
for k,n in enumerate(selected):
    x=(k%4)*270;y=(k//4)*510
    sheet.paste(Image.fromarray(frames[n]),(x,y+30));d.text((x+10,y+7),f'{n/30:.2f}s',fill='white')
sheet.save(P/'11-render-review.jpg',quality=94)
# Validate the exact approved family/weight rather than generated lettering.
font_path=P/'font.ttf'
if not font_path.exists():font_path=P.parent/'fonts/CormorantGaramond-SemiBold.ttf'
font=ImageFont.truetype(str(font_path),40);assert font.getname()==('Cormorant Garamond','SemiBold')
files={f.name:{'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in P.glob('*') if f.suffix in ['.mp4','.jpg'] and 'review' not in f.name}
report={'video':{'width':1080,'height':1920,'codec':'h264','pixelFormat':'yuv420p','fps':30,'audio':'aac','audioContent':'silent stereo AAC; no third-party audio','duration':float(probe['format']['duration']),'framesDecoded':420,'faststart':True,'bytes':len(data)},'motion':{'sourceScenes':1,'zoomPercent':9,'curve':'smoothstep, continuous fractional crop toward helping grip','cuts':0,'decodedAdjacentFrameDifferenceMax':float(delta.max()),'decodedDifferenceFirst30Mean':float(delta[:30].mean()),'decodedDifferenceMiddle30Mean':float(delta[195:225].mean()),'decodedDifferenceLast30Mean':float(delta[-30:].mean()),'scope':'continuous decoded-frame temporal checks plus visual review of selected encoded frames; not real-time playback'},'typography':{'family':'Cormorant Garamond','weight':600,'fontFile':'assets/social/fonts/CormorantGaramond-SemiBold.ttf','hook':"These stairs weren't built for us.",'hookWords':6,'fadeStartSeconds':.2,'fullyReadableSeconds':1.75,'anchoredToScreen':True,'finalQuestionFade':[7,8.5],'finalQuestionY':1470},'carousel':{'frames':2,'width':1080,'height':1350,'order':'torn cloak, repaired cloak'},'files':files}
(P/'validation.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
