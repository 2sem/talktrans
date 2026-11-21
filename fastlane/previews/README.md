# App Store app previews

| Locale | File | Length |
|---|---|---|
| ko | `ko/iphone_6.9.mp4` | 24.5 s |
| en-US | `en-US/iphone_6.9.mp4` | 24.8 s |

886×1920, 30 fps, H.264 + AAC stereo (6.9"/6.5" iPhone slot). First shipped with 2.4.0.

fastlane `deliver` does not upload app previews, so they are uploaded in App Store Connect
(version page → App Preview and Screenshots → iPhone 6.9").

## Rebuild

`source/` holds everything needed to re-render:

- `director-plan.md`: concept, scene table, recording scenario
- `cuts.txt`: `scene clip start end coverStatusBar captionPos`
- `captions_<lang>.txt`: one caption per scene line
- `audio/<lang>NN.mp3`: per-scene narration (edge-tts; kept so re-renders never call the service again)
- `render.sh <ko|en>`: renders `source/out/preview_<lang>.mp4`

Raw screen recordings are not committed. Put `clip01…clip05` in `~/Downloads` (or set `CLIPS=`), then:

```bash
cd fastlane/previews/source && ./render.sh ko && ./render.sh en
```

Needs `ffmpeg` and Python with Pillow (Homebrew ffmpeg has no `drawtext`, so captions are PNG overlays).

## Narration rules

- edge-tts voices: `ko-KR-HyunsuMultilingualNeural` (ko), `en-US-AriaNeural` (en), `--rate=+8%`.
  `edge-tts --voice <voice> --rate=+8% --text "<line>" --write-media audio/<lang>NN.mp3`
- Feed text as written; keep English terms in English (no phonetic Korean respelling).
- Scene length = narration length + 0.4 s (measured with ffprobe). Keep the total under 30 s.
- Listen to key terms (e.g. "TalkTrans") before the final render.
- edge-tts needs internet and uses an unofficial Edge endpoint. Offline fallback is `say`.
  If the app's marketing becomes monetized/sponsored content, switch to Azure Speech (licensed).
