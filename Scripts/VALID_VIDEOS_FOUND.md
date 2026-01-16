# Valid YouTube Videos for Turn Lab

## Critical Finding

**All 22 YouTube video IDs in `videos.json` are invalid placeholders.** They return HTTP 404 because they were never real video IDs.

This needs to be fixed before users encounter dead video links.

## Verified Valid Videos from Research

The following video IDs have been verified as valid from Stomp It Tutorials:

| Video ID | Title | Author | Skill Coverage |
|----------|-------|--------|----------------|
| `_yfFGDuJ2g0` | How to Ski \| 10 Beginner Skills for the First Day Skiing | Stomp It Tutorials | Basic stance, first day |
| `tyB7Wu_aCq8` | How to Ski \| 7 Steps to Parallel Turns | Stomp It Tutorials | Parallel turns |
| `KWqQ4pf2OII` | How to Carve on Skis \| 3 Common Mistakes | Stomp It Tutorials | Carving intro |
| `b2ixGC5uDCE` | How to Ski Powder \| 10 Tips | Stomp It Tutorials | Powder skiing |

## Skills Needing Video Replacements

Based on the skills in the app, here are the video topics needed:

### Beginner Level
- [ ] Basic Stance (`_yfFGDuJ2g0` - covers this)
- [ ] Straight Run / Balance Basics
- [ ] Wedge Position (Pizza)
- [ ] Wedge Turns
- [ ] Stopping

### Novice Level
- [ ] Wedge Christie
- [ ] Traverse
- [ ] Sideslip
- [ ] Speed Control
- [ ] Linked Turns

### Intermediate Level
- [ ] Parallel Turns (`tyB7Wu_aCq8` - covers this)
- [ ] Hockey Stop
- [ ] Carving Introduction (`KWqQ4pf2OII` - covers this)
- [ ] Variable Terrain
- [ ] Short Turns

### Expert Level
- [ ] Advanced Carving
- [ ] Moguls
- [ ] Steep Terrain
- [ ] Powder (`b2ixGC5uDCE` - covers this)
- [ ] Dynamic Short Turns

## Recommended Sources

### Primary Sources (High Quality, Consistent Style)
1. **Stomp It Tutorials** - https://www.youtube.com/@stompittutorials
   - Professional quality, covers all levels
   - Run by Jens Nystrom
   - Best for: Technique, freestyle, all-mountain

2. **Ski School by Elate Media** (SkiSchoolApp) - https://www.youtube.com/@SkiSchoolApp
   - Short, focused lessons
   - Instructor: Darren Turner
   - Best for: Beginner fundamentals

### Secondary Sources
3. **ALLTRACKS Academy** - Mogul and advanced technique specialists
4. **Tom Gellie / Big Picture Skiing** - Advanced carving technique

## How to Update

1. Search YouTube for each skill topic from the recommended channels
2. Copy the video ID from the URL (e.g., `youtube.com/watch?v=XXXXXXXXXXX`)
3. Update `TurnLab/Resources/Content/videos.json` with the new ID
4. Run `python Scripts/validate_youtube_links.py` to verify
5. Test in the app simulator

## Example Video ID Extraction

YouTube URL: `https://www.youtube.com/watch?v=tyB7Wu_aCq8`
Video ID: `tyB7Wu_aCq8` (the 11 characters after `v=`)

## Next Steps

1. Manual content curation required - search YouTube for videos matching each skill
2. Update videos.json with valid IDs
3. Consider reducing number of videos per skill (some skills have 2 videos assigned)
4. Run validation script before each release
