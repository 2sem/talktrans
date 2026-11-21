# TalkTrans App Preview: Director Plan (v2.4.0)

## 0. Specs
- Length: about 25 s (hard limits 15 to 30 s). 7 scenes, 0.3 s crossfades.
- Output: 886x1920 portrait, 30 fps, H.264, AAC stereo 48 kHz. Two versions with the same footage: `preview_ko.mp4` and `preview_en-US.mp4`.
- Source: real iPhone screen recordings (Control Center, mic OFF). Scale the recording to 886 px wide, then center-crop the height to 1920 (a 1320x2868 or 1179x2556 recording loses only about 5 px).
- Audio: edge-tts narration only. **No music, no SFX** (we have no licensed music; the UI is silent anyway).
- Narration voices: ko = `ko-KR-HyunsuMultilingualNeural` for **every** ko scene. The end line has the brand name "TalkTrans" and the voice must stay the same for the whole video. en = `en-US-AriaNeural`.

## 1. Concept and hook
**"Two people, one phone, face to face."** TalkTrans's signature is Table Mode: the phone lies between two people, and the screen splits into a Korean half facing you and an English half facing them, upside down. The video follows one real exchange between a Korean traveler and an English speaker: ask, get the translation, open Table Mode, hear the reply. It also shows the 2.4.0 speech improvements (haptic "Getting ready… → Speak now" cue, tap the mic to restart).

**Hook (0 to 3 s):** open on the finished face-to-face Table Mode screen as a translation lands. The top half (teal, upside down) shows English and the bottom half (amber) shows Korean. With the caption "Face to face. Translated." the value is clear before any explanation.

**Recording language: record ONCE with the app's UI set to English, and reuse that footage for both locales.**
Reasons:
- The speech screen strings are hard-coded English: "Speaking Korean", "Getting ready…", "Speak now", "Restart", "Cancel", "Use & translate" all use `Text(verbatim:)`.
- The main Table Mode strings ("Table Mode", "Speak to reply", "Translate", "THEM", "YOU") have no ko translation, so a Korean-UI recording would still be mostly English. It would only add a few Korean labels ("말하기/입력"), and those would look out of place in the en-US version.
- The conversation itself is Korean <-> English, so Korean viewers see Korean text on screen and English viewers see English. The localized captions and narration carry the meaning.
- Use the per-app language setting (Settings > TalkTrans > Language > English), so the whole phone doesn't have to switch.

## 2. Scene table

Timings are on the final timeline. Narration length is checked against the budget (ko about 6.5 syllables/s, en about 2.6 words/s, plus 0.4 s).

| # | Dur | Source clip / on-screen action | Caption ko | Caption en | Narration ko | Narration en |
|---|-----|--------------------------------|------------|------------|--------------|--------------|
| 1 | 3.0 s | **clip01** tail: speech screen dismisses, Table Mode fills in (top teal panel, upside down: "Thank you, have a nice day!"; bottom amber: "감사합니다, 좋은 하루 보내세요!"). Hold. | 마주 보고 바로 통역 | Face to face. Translated. | 얼굴 보고 바로 통역하세요. (11 syl, about 2.1 s) | Face to face. Instantly translated. (5 w, about 2.3 s) |
| 2 | 5.0 s | **clip02** part A: main screen (Korean -> English), tap **Speak** segment -> speech screen "Speaking Korean", big mic dims, "Getting ready…" -> "Speak now" (mic brightens). Speed up waits 1.5x. | 준비되면 진동으로 알려줘요 | A haptic cue when the mic is live | 마이크가 준비되면 진동으로 알려줘요. 이제 말하세요. (22 syl, about 3.8 s) | A gentle buzz tells you the mic is live. Just speak. (11 w, about 4.6 s) |
| 3 | 3.8 s | **clip02** part B: false start "지하철역은…" appears -> tap big mic -> text clears -> "Getting ready… -> Speak now" -> "화장실이 어디에 있나요?" types in. (2.4.0 highlight) | 마이크를 탭하면 처음부터 다시 | Tap the mic to start over | 다시 말하고 싶으면 마이크를 탭하세요. (16 syl, about 2.9 s) | Want a redo? Tap the mic to start over. (8 w, about 3.5 s) |
| 4 | 3.0 s | **clip02** part C: tap **Use & translate** -> main screen: amber YOU card "화장실이 어디에 있나요?", teal THEM card "Where is the restroom?" | 탭 한 번으로 번역 | One tap to translate | 탭 한 번이면 바로 번역돼요. (11 syl, about 2.1 s) | One tap, and it's translated. (5 w, about 2.3 s) |
| 5 | 4.2 s | **clip03**: tap the **Table Mode** button (two-person icon right of Translate) -> split screen scales in. Hold. | 테이블 모드 · 각자 자기 방향으로 | Table Mode: each side reads their own | 테이블 모드로 펼치면, 마주 앉은 상대도 바로 읽어요. (22 syl, about 3.8 s) | Table Mode: they read their side, right-side up. (8 w, about 3.5 s) |
| 6 | 5.0 s | **clip04** (about 2x on waits): tap center **↑↓** swap -> tap **🎤 Speak to reply** -> "Speaking English" -> say reply -> **Use & translate** -> top panel shows Korean upside down, bottom shows English. | 상대방 대답도 바로 통역 | Their reply, translated back | 버튼 하나로 방향을 바꾸면, 상대방의 대답도 통역돼요. (22 syl, about 3.8 s) | Flip directions with one tap, and their reply comes right back. (11 w, about 4.6 s) |
| 7 | 2.5 s | **clip05**: clean main screen with the TalkTrans header and the translated pair; slow 105% push-in. Caption centered, large. | TalkTrans · 여행 대화를 쉽게 | TalkTrans · Travel talk, made easy | 여행 대화, 이제 TalkTrans로. (about 11 syl, about 2.1 s) | Travel talk, made easy. TalkTrans. (5 w, about 2.3 s) |

Total is about 26.5 s before the six 0.3 s crossfades, about 24.7 s after. If any ko TTS clip comes out longer than its scene minus 0.4 s, extend that scene by holding the last frame (the total stays under 30 s), and don't speed up the voice.

**Caption style:** bold rounded sans (SF Pro Rounded or Pretendard Bold for ko), white text on a 70% black rounded pill. Place it in the lower third, but put it at the **top** in scenes 2 and 3, because the speech buttons are at the bottom. In scenes 1, 5 and 6, place it over the center seam between the two halves without covering the ↑↓ button, or else at the bottom, above the "Speak to reply" pill. Fade in and out over 0.2 s.

**Status bar:** Table Mode hides the status bar. In the main-screen and speech-screen shots, cover the top roughly 60 px (after scaling) with a background-colored band (#0C0E14 in dark mode). That hides the red recording pill and the clock.

**Edit checks (Apple):** no prices, no "best/#1" claims, only real features. "Instantly" matches the store description ("즉시 번역").

## 3. Recording scenario for the user (iPhone, about 10 min)

You can speak **both sides** yourself (Korean and English), so no second person is needed. Record each clip separately and AirDrop them as `clip01.mov` … `clip05.mov`. Shoot them in the order below, which is **not** the clip-number order, because each clip sets up the next.

### A. Setup (about 3 min)
1. **Focus > Do Not Disturb ON** (no banners). Wi-Fi ON, battery above 50% or charging, Low Power Mode OFF, Personal Hotspot/CarPlay OFF.
2. **Settings > Display & Brightness > Dark** (all clips in dark mode).
3. **Settings > TalkTrans > Language > English** (app-only language; the phone stays Korean).
4. **Portrait Orientation Lock ON.** Hold the phone upright the whole time. Table Mode rotates the top half inside the app, so you never turn the phone.
5. Open TalkTrans. Tap the **ad/gift button** (top-right, next to the clock icon) and watch the reward ad to turn on ad-free time, so no banner appears in the footage. If a full-screen ad ever appears mid-take, just retake.
6. Set languages: **top card (YOU) = Korean, bottom card (THEM) = English.** Clear any text in the input card.
7. Control Center: **long-press the Screen Recording button > make sure Microphone is OFF** (it shows "Microphone Off"). Narration replaces all audio.
8. Use a quiet room. Speak clearly at a normal pace. For every clip: start recording, **wait 1 s still**, do the actions, **wait 2 s still**, stop recording.

### B. Shot list

**clip02: Speak, restart, translate** (shoot 2 takes)
1. Start on the main screen: Korean -> English, input empty.
2. Start recording. Wait 1 s.
3. Tap **Speak** (mic segment at the top). The speech screen opens with "Speaking Korean".
4. Wait until "Getting ready…" changes to **"Speak now"** (you'll feel a tap). Hold 1 s.
5. Say a deliberate false start in Korean: **"지하철역은…"** Then stop talking.
6. Tap the **big mic**. The text clears and shows "Getting ready…" again. Wait for **"Speak now"**.
7. Say clearly in Korean: **"화장실이 어디에 있나요?"** Wait 1.5 s for the text to settle.
8. Tap **Use & translate**. The main screen shows "Where is the restroom?" Hold 2 s. Stop recording.

**clip03: Open Table Mode** (2 takes; between takes, tap the X to go back)
1. Stay on the main screen with that translation showing.
2. Start recording. Wait 1 s.
3. Tap the **two-person button** to the right of Translate. The split screen appears.
4. Hold 3 s without touching anything. Stop recording. **Stay in Table Mode.**

**clip04: Reply from the other side** (2 takes)
1. In Table Mode, start recording. Wait 1 s.
2. Tap the round **↑↓ button** in the center. The bottom half becomes English.
3. Tap **🎤 Speak to reply**. Wait for **"Speak now"**.
4. Say in English: **"It's down the hall, on the left."** Wait 1.5 s.
5. Tap **Use & translate**. Table Mode returns with Korean in the top (upside-down) half. Hold 3 s. Stop recording.

**clip01: Hook** (2 takes)
1. Still in Table Mode, tap **↑↓** once so the bottom half is Korean again. Don't record this.
2. Start recording. Wait 1 s.
3. Tap **🎤 Speak to reply**. Wait for **"Speak now"**.
4. Say in Korean: **"감사합니다, 좋은 하루 보내세요!"** Wait 1.5 s.
5. Tap **Use & translate**. Table Mode fills in with English on top. **Hold 4 s** (this is the opening shot). Stop recording.

**clip05: End card** (1 take)
1. Tap the **X** (top-right of the bottom half) to leave Table Mode.
2. Start recording and hold the main screen still for 4 s, touching nothing. Stop recording.

### C. After shooting
- AirDrop the best take of each clip, named `clip01.mov` … `clip05.mov`.
- Optional: switch Settings > TalkTrans > Language back to Korean.
- Retake a clip if: a notification or ad appears, recognition misheard a phrase, or the keyboard popped up.

## 4. Music / SFX
None. We have no licensed music, and an unlicensed track risks App Review rejection. Narration over the silent UI is clean and keeps the focus on the translation. If it feels too dry, leave about 0.3 s of silence between scenes instead of adding sound.
