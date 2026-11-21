#!/bin/bash
# Usage: render.sh <ko|en>
# cuts.txt lines: scene clipfile start end cover(0/1) capPos(top|bottom|center)
# Scene length = narration length + 0.4s; footage is speed-fitted to it.
set -euo pipefail
cd "$(dirname "$0")"
L=$1
CLIPS=${CLIPS:-$HOME/Downloads}
OUT=out/$L; mkdir -p "$OUT"
FONT="/System/Library/Fonts/AppleSDGothicNeo.ttc"
BG="0x0C0E14"

i=0
: > "$OUT/list.txt"
while read -r scene clip start end cover pos; do
	[[ -z "${scene:-}" || "$scene" == \#* ]] && continue
	nn=$(printf "%02d" "$scene")
	aud="audio/${L}${nn}.mp3"
	adur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$aud")
	sdur=$(echo "$adur + 0.4" | bc)
	src=$(echo "$end - $start" | bc)
	factor=$(echo "scale=4; $sdur / $src" | bc)
	cap=$(sed -n "${scene}p" "captions_${L}.txt")
	python3 caption.py "$cap" "$pos" "$OUT/cap$nn.png"
	cov=""; [[ "$cover" == 1 ]] && cov=",drawbox=x=0:y=0:w=iw:h=120:color=${BG}:t=fill"
	fout=$(echo "$sdur - 0.2" | bc)
	ffmpeg -nostdin -v error -y -ss "$start" -to "$end" -i "$CLIPS/$clip" -i "$aud" -loop 1 -t "$sdur" -i "$OUT/cap$nn.png" -filter_complex "
		[0:v]setpts=${factor}*(PTS-STARTPTS),fps=30,scale=886:-2:flags=lanczos,crop=886:1920:0:(ih-1920)/2${cov},
		tpad=stop_mode=clone:stop_duration=2,trim=duration=${sdur},setsar=1[base];
		[2:v]format=rgba,fade=t=in:st=0:d=0.2:alpha=1,fade=t=out:st=${fout}:d=0.2:alpha=1[cap];
		[base][cap]overlay=0:0:shortest=1,format=yuv420p[v];
		[1:a]adelay=150|150,apad,atrim=duration=${sdur},aformat=sample_rates=48000:channel_layouts=stereo[a]" \
		-map "[v]" -map "[a]" -c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -c:a aac -b:a 256k "$OUT/s$nn.mp4"
	echo "file 's$nn.mp4'" >> "$OUT/list.txt"
	echo "scene $nn: ${sdur}s (footage x$factor)"
done < cuts.txt

ffmpeg -nostdin -v error -y -f concat -safe 0 -i "$OUT/list.txt" -c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -r 30 \
	-profile:v high -level 4.0 -c:a aac -b:a 256k -ar 48000 -ac 2 -movflags +faststart "out/preview_${L}.mp4"
ffprobe -v error -show_entries format=duration:stream=width,height,r_frame_rate,codec_name -of compact "out/preview_${L}.mp4"
