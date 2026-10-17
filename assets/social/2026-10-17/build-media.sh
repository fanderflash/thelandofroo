#!/usr/bin/env bash
set -euo pipefail
roo_root="/workspace/scratch/3531d8ee1038/assets/social/2026-10-17"
roo_gen="/workspace/scratch/3531d8ee1038/generated_images"
font="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
mkdir -p "$roo_root/reel" "$roo_root/carousel"
cp "$roo_gen/exec-1d9b4e55-8278-4c60-bde1-a57ff4771acf.png" "$roo_root/reel/scene-01.png"
cp "$roo_gen/exec-15108693-8ed8-48de-a83b-0fd8e383fd2e.png" "$roo_root/reel/scene-02.png"
cp "$roo_gen/exec-843d2326-8453-41ea-9ab1-270b51b17887.png" "$roo_root/reel/scene-03.png"
cp "$roo_gen/exec-dcc4bf60-22ce-4895-872c-62f81f04bec1.png" "$roo_root/carousel/source-01.png"
cp "$roo_gen/exec-024476b6-bd50-427d-9cdd-e39a15e4bf73.png" "$roo_root/carousel/source-02.png"
reel_frame() {
 local n="$1" title="$2" sub="$3"
 ffmpeg -hide_banner -loglevel error -y -i "$roo_root/reel/scene-$n.png" -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,drawbox=x=45:y=195:w=990:h=140:color=black@0.72:t=fill,drawtext=fontfile=${font}:text='$title':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=242,drawbox=x=60:y=1550:w=960:h=115:color=black@0.68:t=fill,drawtext=fontfile=${font}:text='$sub':fontcolor=white:fontsize=38:x=(w-text_w)/2:y=1588" -q:v 2 "$roo_root/reel/frame-$n.jpg"
}
reel_frame 01 "SHE HAD ONE LIVING EMBER" "TWO PEOPLE NEEDED ITS WARMTH"
reel_frame 02 "TRUTH STRENGTHENS WHAT EXISTS" "IT NEEDS A REAL FOUNDATION"
reel_frame 03 "ONE EMBER. TWO PEOPLE WARM." "WHAT IF IT HAD GONE OUT?"
ffmpeg -hide_banner -loglevel error -y -loop 1 -t 2.5 -i "$roo_root/reel/frame-01.jpg" -loop 1 -t 3.5 -i "$roo_root/reel/frame-02.jpg" -loop 1 -t 4 -i "$roo_root/reel/frame-03.jpg" -f lavfi -t 10 -i "anoisesrc=color=brown:amplitude=0.012:r=48000:d=10" -filter_complex "[0:v]fps=30,format=yuv420p[v0];[1:v]fps=30,format=yuv420p[v1];[2:v]fps=30,format=yuv420p[v2];[v0][v1][v2]concat=n=3:v=1:a=0[v];[3:a]highpass=f=100,lowpass=f=1800,afade=t=in:st=0:d=0.5,afade=t=out:st=9:d=1[a]" -map "[v]" -map "[a]" -c:v libx264 -preset medium -crf 20 -profile:v high -pix_fmt yuv420p -r 30 -c:a aac -b:a 96k -ar 48000 -ac 1 -movflags +faststart -shortest "$roo_root/01-one-living-ember-reel.mp4"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/carousel/source-01.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=35:y=30:w=1010:h=120:color=black@0.72:t=fill,drawtext=fontfile=${font}:text='HE BROUGHT ALMOST NOTHING HOME':fontcolor=white:fontsize=42:x=(w-text_w)/2:y=72,drawbox=x=65:y=1200:w=950:h=100:color=black@0.68:t=fill,drawtext=fontfile=${font}:text='SWIPE TO OPEN THE PARCEL':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=1230" -q:v 2 "$roo_root/carousel/01-the-small-parcel.jpg"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/carousel/source-02.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=40:y=1170:w=1000:h=130:color=black@0.72:t=fill,drawtext=fontfile=${font}:text='BUT HE HAD REMEMBERED.':fontcolor=white:fontsize=46:x=(w-text_w)/2:y=1215" -q:v 2 "$roo_root/carousel/02-the-carved-horse.jpg"
if [[ -n "${1:-}" ]]; then
 cp "$1" "$roo_root/serial-source.png"
 ffmpeg -hide_banner -loglevel error -y -i "$roo_root/serial-source.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=45:y=20:w=990:h=70:color=black@0.68:t=fill,drawtext=fontfile=${font}:text='FIRESIDE TALES OF ROO':fontcolor=white:fontsize=34:x=(w-text_w)/2:y=40,drawbox=x=45:y=1190:w=990:h=115:color=black@0.72:t=fill,drawtext=fontfile=${font}:text='SHE FINALLY TOLD SOMEONE':fontcolor=white:fontsize=46:x=(w-text_w)/2:y=1225" -q:v 2 "$roo_root/03-she-finally-told-someone.jpg"
fi
