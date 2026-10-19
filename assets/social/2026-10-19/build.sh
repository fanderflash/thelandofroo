#!/usr/bin/env bash
set -euo pipefail
roo_root="/workspace/scratch/3531d8ee1038/assets/social/2026-10-19"
font="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
mkdir -p "$roo_root/reel" "$roo_root/carousel"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-0590bff0-fb70-4830-bf3d-51788ba4d47d.png" "$roo_root/reel/scene-01.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-3f2d8795-207e-467d-88f9-7dade23bfe4d.png" "$roo_root/reel/scene-02.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-1a1e4e9f-66f9-4b55-83da-236fc7910eb3.png" "$roo_root/reel/scene-03.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-7c327eae-6f87-4b97-890f-500de0efdb93.png" "$roo_root/carousel/source-01.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-50a68a42-a735-4519-99df-22cd4d37273b.png" "$roo_root/carousel/source-02.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-d0865a2f-b1af-481a-9430-53c63bea95be.png" "$roo_root/serial-source.png"
reel_frame() {
 local n="$1" title="$2" sub="$3"
 ffmpeg -hide_banner -loglevel error -y -i "$roo_root/reel/scene-$n.png" -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,drawbox=x=45:y=170:w=990:h=125:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='$title':fontcolor=white:fontsize=46:x=(w-text_w)/2:y=210,drawbox=x=60:y=1580:w=960:h=110:color=black@0.70:t=fill,drawtext=fontfile=${font}:text='$sub':fontcolor=white:fontsize=38:x=(w-text_w)/2:y=1617" -q:v 2 "$roo_root/reel/frame-$n.jpg"
}
reel_frame 01 "THE GOLD WAS A LIE" "HE WANTED HER LAST COINS"
reel_frame 02 "HIS CERTAINTY BROKE FIRST" "LIE MAGIC NEEDS CONVICTION"
reel_frame 03 "THEN THE GOLD WAS GONE" "WOULD YOU HAVE PAID?"
ffmpeg -hide_banner -loglevel error -y -loop 1 -t 2 -i "$roo_root/reel/frame-01.jpg" -loop 1 -t 3 -i "$roo_root/reel/frame-02.jpg" -loop 1 -t 5.5 -i "$roo_root/reel/frame-03.jpg" -f lavfi -t 10.5 -i "anoisesrc=color=brown:amplitude=0.012:r=48000:d=10.5" -filter_complex "[0:v]fps=30,format=yuv420p[v0];[1:v]fps=30,format=yuv420p[v1];[2:v]fps=30,format=yuv420p[v2];[v0][v1][v2]concat=n=3:v=1:a=0[v];[3:a]highpass=f=100,lowpass=f=1800,afade=t=in:st=0:d=0.5,afade=t=out:st=9.5:d=1[a]" -map "[v]" -map "[a]" -c:v libx264 -preset medium -crf 20 -profile:v high -pix_fmt yuv420p -r 30 -c:a aac -b:a 96k -ar 48000 -ac 1 -movflags +faststart -shortest "$roo_root/01-the-gold-was-a-lie.mp4"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/carousel/source-01.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=35:y=25:w=1010:h=100:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='WHAT WOULD YOU BUILD HERE?':fontcolor=white:fontsize=43:x=(w-text_w)/2:y=57,drawbox=x=65:y=1220:w=950:h=90:color=black@0.70:t=fill,drawtext=fontfile=${font}:text='SWIPE FOR HER ANSWER':fontcolor=white:fontsize=37:x=(w-text_w)/2:y=1249" -q:v 2 "$roo_root/carousel/01-what-would-you-build.jpg"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/carousel/source-02.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=40:y=1210:w=1000:h=100:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='BREAD, NOT BURIED TREASURE':fontcolor=white:fontsize=43:x=(w-text_w)/2:y=1242" -q:v 2 "$roo_root/carousel/02-bread-not-buried-treasure.jpg"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/serial-source.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=45:y=18:w=990:h=65:color=black@0.70:t=fill,drawtext=fontfile=${font}:text='FIRESIDE TALES OF ROO':fontcolor=white:fontsize=34:x=(w-text_w)/2:y=36,drawbox=x=45:y=1250:w=990:h=75:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='THE FOOTPRINTS WERE HIS':fontcolor=white:fontsize=39:x=(w-text_w)/2:y=1273" -q:v 2 "$roo_root/03-the-footprints-were-his.jpg"
