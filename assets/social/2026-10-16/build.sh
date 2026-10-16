#!/usr/bin/env bash
set -euo pipefail
root="/workspace/scratch/3531d8ee1038/assets/social/2026-10-16"
gen="/workspace/scratch/3531d8ee1038/generated_images"
font="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
mkdir -p "$root/reel" "$root/carousel"
cp "$gen/exec-cdfd21a1-fdd1-4e03-9021-87521026e1e5.png" "$root/reel/scene-01.png"
cp "$gen/exec-27c8454f-44f5-4e73-acef-253da59bfb32.png" "$root/reel/scene-02.png"
cp "$gen/exec-fa502975-1252-4600-8b1f-a91f2a720c48.png" "$root/reel/scene-03.png"
cp "$gen/exec-35424aa1-4890-4b4c-b479-5e5bf56bb0ca.png" "$root/carousel/source-01.png"
cp "$gen/exec-526217b4-11e2-4e13-abd5-763c7739385a.png" "$root/carousel/source-02.png"
cp "$gen/exec-e2e38754-04ef-4def-8345-e36846016f7e.png" "$root/serial-source.png"
reel_frame() {
 local n="$1" title="$2" sub="$3"
 ffmpeg -hide_banner -loglevel error -y -i "$root/reel/scene-$n.png" -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,drawbox=x=45:y=200:w=990:h=145:color=black@0.68:t=fill,drawtext=fontfile=${font}:text='$title':fontcolor=white:fontsize=50:x=(w-text_w)/2:y=245,drawbox=x=60:y=1510:w=960:h=120:color=black@0.65:t=fill,drawtext=fontfile=${font}:text='$sub':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=1550" -q:v 2 "$root/reel/frame-$n.jpg"
}
reel_frame 01 "THIS CITY HIDES A SECRET" "LOOK PAST THE HOUSES"
reel_frame 02 "TOO LARGE FOR HUMAN HANDS" "FOLLOW THE STONE"
reel_frame 03 "BUILT ON VANIR RUINS" "WOULD YOU LIVE HERE?"
ffmpeg -hide_banner -loglevel error -y -loop 1 -t 3 -i "$root/reel/frame-01.jpg" -loop 1 -t 4 -i "$root/reel/frame-02.jpg" -loop 1 -t 5 -i "$root/reel/frame-03.jpg" -f lavfi -t 12 -i "anoisesrc=color=brown:amplitude=0.014:r=48000:d=12" -filter_complex "[0:v]fps=30,format=yuv420p[v0];[1:v]fps=30,format=yuv420p[v1];[2:v]fps=30,format=yuv420p[v2];[v0][v1][v2]concat=n=3:v=1:a=0[v];[3:a]highpass=f=100,lowpass=f=1800,afade=t=in:st=0:d=1,afade=t=out:st=11:d=1[a]" -map "[v]" -map "[a]" -c:v libx264 -preset medium -crf 20 -profile:v high -pix_fmt yuv420p -r 30 -c:a aac -b:a 96k -ar 48000 -ac 1 -movflags +faststart -shortest "$root/01-highwards-hidden-foundation-reel.mp4"
ffmpeg -hide_banner -loglevel error -y -i "$root/carousel/source-01.png" -vf "scale=1080:1350,drawbox=x=35:y=45:w=1010:h=130:color=black@0.68:t=fill,drawtext=fontfile=${font}:text='THAT IS MOSS. NOT A TREE.':fontcolor=white:fontsize=46:x=(w-text_w)/2:y=87,drawbox=x=65:y=1200:w=950:h=100:color=black@0.65:t=fill,drawtext=fontfile=${font}:text='SWIPE TO SEE THE SCALE':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=1230" -q:v 2 "$root/carousel/01-that-is-moss.jpg"
ffmpeg -hide_banner -loglevel error -y -i "$root/carousel/source-02.png" -vf "scale=1080:1350,drawbox=x=40:y=1110:w=1000:h=180:color=black@0.68:t=fill,drawtext=fontfile=${font}:text='SHE WAS RIGHT THERE.':fontcolor=white:fontsize=46:x=(w-text_w)/2:y=1145,drawtext=fontfile=${font}:text='MITTEN OR FACE - WHAT CAME FIRST?':fontcolor=white:fontsize=33:x=(w-text_w)/2:y=1220" -q:v 2 "$root/carousel/02-she-was-right-there.jpg"
ffmpeg -hide_banner -loglevel error -y -i "$root/serial-source.png" -vf "scale=1080:1350,drawbox=x=45:y=20:w=990:h=70:color=black@0.66:t=fill,drawtext=fontfile=${font}:text='FIRESIDE TALES OF ROO':fontcolor=white:fontsize=34:x=(w-text_w)/2:y=40,drawbox=x=45:y=1190:w=990:h=115:color=black@0.68:t=fill,drawtext=fontfile=${font}:text='SHE BURNED THE DRAWING':fontcolor=white:fontsize=46:x=(w-text_w)/2:y=1225" -q:v 2 "$root/03-she-burned-the-drawing.jpg"
