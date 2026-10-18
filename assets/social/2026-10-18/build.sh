#!/usr/bin/env bash
set -euo pipefail
roo_root="/workspace/scratch/3531d8ee1038/assets/social/2026-10-18"
font="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
mkdir -p "$roo_root/reel" "$roo_root/carousel"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-58f0a973-2b5a-4174-9562-75bcdd1e8c0d.png" "$roo_root/reel/scene-01.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-58fbe7f8-38f1-4d2e-b606-e243ae5fee56.png" "$roo_root/reel/scene-02.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-eeff7696-2818-404b-b2d0-f46a8072f18e.png" "$roo_root/reel/scene-03.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-12a5b2fb-053e-40c6-86cb-d4fdca5f891e.png" "$roo_root/carousel/source-01.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-31a8dcbe-c866-4b5d-9d4b-6326013b390b.png" "$roo_root/carousel/source-02.png"
cp "/workspace/scratch/3531d8ee1038/generated_images/exec-f038abd5-a2e0-4dae-abdc-7728a8b47b1b.png" "$roo_root/serial-source.png"
reel_frame() {
 local n="$1" title="$2" sub="$3"
 ffmpeg -hide_banner -loglevel error -y -i "$roo_root/reel/scene-$n.png" -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,drawbox=x=45:y=170:w=990:h=125:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='$title':fontcolor=white:fontsize=46:x=(w-text_w)/2:y=210,drawbox=x=60:y=1580:w=960:h=110:color=black@0.70:t=fill,drawtext=fontfile=${font}:text='$sub':fontcolor=white:fontsize=38:x=(w-text_w)/2:y=1617" -q:v 2 "$roo_root/reel/frame-$n.jpg"
}
reel_frame 01 "SHE CUT UP HER BEST CLOAK" "THE SAIL HAD TORN"
reel_frame 02 "STITCH BY STITCH" "HER CLOAK BECAME THEIR PATCH"
reel_frame 03 "IT CARRIED THEM HOME" "WOULD YOU HAVE CUT YOURS?"
ffmpeg -hide_banner -loglevel error -y -loop 1 -t 2.5 -i "$roo_root/reel/frame-01.jpg" -loop 1 -t 3.5 -i "$roo_root/reel/frame-02.jpg" -loop 1 -t 4.5 -i "$roo_root/reel/frame-03.jpg" -f lavfi -t 10.5 -i "anoisesrc=color=brown:amplitude=0.012:r=48000:d=10.5" -filter_complex "[0:v]fps=30,format=yuv420p[v0];[1:v]fps=30,format=yuv420p[v1];[2:v]fps=30,format=yuv420p[v2];[v0][v1][v2]concat=n=3:v=1:a=0[v];[3:a]highpass=f=100,lowpass=f=1800,afade=t=in:st=0:d=0.5,afade=t=out:st=9.5:d=1[a]" -map "[v]" -map "[a]" -c:v libx264 -preset medium -crf 20 -profile:v high -pix_fmt yuv420p -r 30 -c:a aac -b:a 96k -ar 48000 -ac 1 -movflags +faststart -shortest "$roo_root/01-the-cloak-that-carried-them-home.mp4"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/carousel/source-01.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=35:y=25:w=1010:h=100:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='SHE BROUGHT THE WRONG BASKET':fontcolor=white:fontsize=43:x=(w-text_w)/2:y=57,drawbox=x=65:y=1220:w=950:h=90:color=black@0.70:t=fill,drawtext=fontfile=${font}:text='SWIPE TO SEE HOW IT GOT HOME':fontcolor=white:fontsize=37:x=(w-text_w)/2:y=1249" -q:v 2 "$roo_root/carousel/01-the-wrong-basket.jpg"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/carousel/source-02.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=40:y=1210:w=1000:h=100:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='ONE MUSHROOM. TWO FRIENDS.':fontcolor=white:fontsize=43:x=(w-text_w)/2:y=1242" -q:v 2 "$roo_root/carousel/02-one-mushroom-two-friends.jpg"
ffmpeg -hide_banner -loglevel error -y -i "$roo_root/serial-source.png" -vf "scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,drawbox=x=45:y=18:w=990:h=65:color=black@0.70:t=fill,drawtext=fontfile=${font}:text='FIRESIDE TALES OF ROO':fontcolor=white:fontsize=34:x=(w-text_w)/2:y=36,drawbox=x=45:y=1250:w=990:h=75:color=black@0.74:t=fill,drawtext=fontfile=${font}:text='SHE CHOSE HER OWN GUIDE':fontcolor=white:fontsize=39:x=(w-text_w)/2:y=1273" -q:v 2 "$roo_root/03-she-chose-her-own-guide.jpg"
