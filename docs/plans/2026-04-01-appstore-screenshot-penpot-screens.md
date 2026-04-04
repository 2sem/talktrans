# App Store Screenshot Penpot Screens Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create four screenshot-ready inner app screens in Penpot for the current `#76` App Store plan: landscape full translated text, voice input, language selection, and history.

**Architecture:** Build the screens directly in the connected Penpot file as separate boards/artboards inside the current English page, keeping visual language consistent with TalkTrans and excluding device mockups or final App Store composite layouts. Reuse a shared screenshot style across all four boards so the set feels cohesive and easy to place into manual iPhone mock frames later.

**Tech Stack:** Penpot MCP tools, existing `#76` screenshot plan, TalkTrans app visual styling.

---

### Task 1: Create the landscape hero screen

**Files:**
- Create in Penpot: `Frame 1` inner board named `Landscape App Screen`

**Step 1: Remove any prior temporary landscape screen board**

Expected: only one final `Landscape App Screen` remains.

**Step 2: Create the landscape inner app board**

- Size it for a landscape screenshot composition inside `Frame 1`
- Use TalkTrans-inspired gradient background
- Add generous rounded corners

**Step 3: Add the translated hero text**

- Use large centered Korean text
- Keep the screen uncluttered
- Suggested text: `서울역으로\n가 주세요`

**Step 4: Verify readability**

Expected: text is legible at thumbnail size and clearly communicates full-screen translation display.


### Task 2: Create the voice input screen

**Files:**
- Create in Penpot: `Frame 2` inner board named `Voice Input Screen`

**Step 1: Create the board using the same screenshot style system**

- Match spacing, corner radius, and palette from Task 1

**Step 2: Add speech-recognition UI state**

- Include active listening emphasis
- Include visible recognized phrase
- Keep enough structure to imply current shipped UI, not future Conversation Mode

**Step 3: Add realistic speech content**

- Suggested phrase: `How much is this?`

**Step 4: Verify screenshot purpose**

Expected: the board immediately communicates “speak naturally, translate instantly”.


### Task 3: Create the language selection screen

**Files:**
- Create in Penpot: `Frame 3` inner board named `Language Selection Screen`

**Step 1: Create the board using the same screenshot style system**

**Step 2: Add a clean language picker layout**

- Show multiple language rows with flags and names
- Ensure Korean, English, Japanese, and Chinese are clearly visible

**Step 3: Keep content screenshot-focused**

- Avoid excessive controls
- Emphasize breadth and clarity

**Step 4: Verify screenshot purpose**

Expected: the board communicates “13 languages, zero barriers”.


### Task 4: Create the history screen

**Files:**
- Create in Penpot: `Frame 4` inner board named `History Screen`

**Step 1: Create the board using the same screenshot style system**

**Step 2: Add realistic history content**

- Multiple saved rows
- Visible pairing of source/translated text
- Dates/times or grouping if it improves readability
- Optionally one favorite/starred item

**Step 3: Keep layout clean for App Store use**

- Prioritize recognizability over density

**Step 4: Verify screenshot purpose**

Expected: the board communicates “your translations, ready anytime”.


### Task 5: Final consistency review in Penpot

**Files:**
- Review in Penpot: `Frame 1`, `Frame 2`, `Frame 3`, `Frame 4`

**Step 1: Check visual consistency**

- color harmony
- corner radius
- spacing rhythm
- typography hierarchy

**Step 2: Check message hierarchy**

- each board should communicate one idea only

**Step 3: Confirm exclusions**

- no iPhone mock
- no App Store caption layout
- no future Conversation Mode screen
