# Turn Lab - Product Specification

> **App Name:** Turn Lab
> **Version:** 1.0
> **Last Updated:** January 2026

---

## 1. Executive Summary

Turn Lab is an iOS instructional app that guides skiers through a structured skill progression from Beginner to Expert. The app surfaces curated video content, tips, drills, and safety information informed by PSIA/AASI methodology, designed to be useful before, during, and after ski sessions.

### Core Value Proposition
- **Structured progression** vs. random YouTube discovery
- **Personalized tracking** with outcome-based benchmarks
- **On-mountain utility** designed for actual ski sessions, not just home viewing

### Target Launch
Mid ski season (Northern Hemisphere Winter 2025-26)

---

## 2. Problem Statement

Skiers who want to improve face these challenges:
1. **Fragmented content** - Quality instruction exists on YouTube but is scattered and unorganized
2. **No clear progression path** - Hard to know what to learn next or if you're ready to advance
3. **Impractical for the mountain** - Most instructional content is designed for home viewing, not chairlift reference
4. **No feedback mechanism** - Difficult to assess strengths, weaknesses, and progress

### Target Users
- Self-directed skiers at all levels (Beginner through Expert)
- Those who experience the gap between lessons and self-practice
- Skiers who want to improve but can't afford regular instruction

---

## 3. Skill Taxonomy & Progression Model

### Recommended Architecture

Based on PSIA/AASI methodology and your requirements, I recommend a **hybrid taxonomy** with:

#### 3.1 Primary Structure: Level-Based Progression (Default View)

```
Beginner
├── Fundamental Skills (flat list)
│   ├── Basic Stance & Balance
│   ├── Straight Run & Speed Control
│   ├── Wedge Position
│   ├── Wedge Turns
│   └── Stopping
│
Novice
├── Fundamental Skills
│   ├── Wedge Christie
│   ├── Traverse
│   ├── Sideslip
│   └── ...
│
Intermediate
├── Skills grouped by focus area
│   ├── Turn Shape & Control
│   ├── Varied Terrain Introduction
│   └── ...
│
Expert
├── Advanced Skills
│   ├── Carving
│   ├── Bumps/Moguls
│   ├── Steeps
│   └── ...
```

#### 3.2 Secondary Structure: Domain Categories (Exploration View)

Cross-cutting skill domains that span all levels:

| Domain | Description | Example Skills |
|--------|-------------|----------------|
| **Balance & Stance** | Body position, weight distribution, center of mass | Athletic stance, fore/aft balance, angulation |
| **Edge Control** | Using ski edges to grip and shape turns | Edge angles, edge-to-edge transitions, carving |
| **Rotary Movements** | Steering and turning mechanics | Leg rotation, upper/lower body separation |
| **Pressure Management** | Weight transfer and ski loading | Extension/flexion, absorption, unweighting |
| **Terrain Adaptation** | Adjusting to conditions | Bumps, steeps, powder, ice, crud |

#### 3.3 Skill Attributes

Each skill should have:
- **Level**: Beginner/Novice/Intermediate/Expert
- **Domain(s)**: Primary domain category
- **Prerequisites**: Skills that should be mastered first
- **Outcome Milestones**: Observable achievements that indicate proficiency
- **Contextual Variations**: How skill differs on groomed/bumps/powder/steeps

#### 3.4 Progression Logic

**Structured Path (Recommended Default):**
1. Users complete skills within their current level
2. Must achieve "Confident" on 80% of level skills to unlock next level
3. Prerequisites within a level are soft-gated (suggested order, not enforced)

**Self-Exploration (Alternative):**
1. All skills visible with level badges
2. Users can explore any skill but see "recommended" path
3. Can self-assess on any skill regardless of level

### PSIA Methodology Note

Turn Lab is **informed by** PSIA/AASI methodology but does **not claim official alignment or endorsement**. The skill taxonomy and progression model are researched and developed based on:
- PSIA Alpine Technical Manual concepts
- Standard ski instruction progression patterns
- Common skill development frameworks

This allows flexibility while maintaining pedagogically sound progression.

---

## 4. User Experience

### 4.1 First-Time Experience

**Skill Assessment Quiz**
- Scenario-based questions (10-15 questions)
- Example: "When skiing a blue groomed run, you typically..."
  - A) Focus on making wedge turns to control speed
  - B) Link parallel turns comfortably
  - C) Vary turn shape based on terrain features
  - D) Rarely ski blues, prefer more challenging terrain
- Quiz places user at starting level with initial skill assessments

### 4.2 Usage Contexts

Content-driven discovery (implicit modes based on content type):

| Context | Content Type | Characteristics |
|---------|--------------|-----------------|
| **Pre-Session Prep** | Full videos, detailed drills, checklists | Deep content for planning what to practice |
| **On-Mountain** | Quick tips, visual cues, abbreviated reminders | Offline-capable, glove-friendly, high contrast |
| **Post-Session Review** | Self-assessment prompts, progress tracking, next steps | Reflection and planning |

### 4.3 Self-Assessment System

**Inline Assessment (v1.1+):**
- Assessments are performed directly on the Skill Detail screen (no modal sheets)
- Single tap or drag to save - auto-saves immediately with visual feedback
- Celebration animation when user improves a rating

**Continuous Slider Interface:**
- Draggable thumb with emoji progression (🌱→🌿→🌲→⭐)
- Haptic feedback when crossing rating thresholds
- Spring animation snaps to nearest rating on release
- Benchmark descriptions update in real-time as user drags

**Rating Levels (Encouraging Language):**
| Rating | Display Name | Emoji |
|--------|--------------|-------|
| Needs Work | "Building" | 🌱 |
| Developing | "Growing" | 🌿 |
| Confident | "Solid" | 🌲 |
| Mastered | "Expert" | ⭐ |

**Assessment Format:**
- Outcome-based with contextual variations
- Example for "Parallel Turns":
  - On groomed blues: Drag slider to rate
  - On groomed blacks: Drag slider to rate
  - In variable snow: Drag slider to rate

**Benchmark Display:**
- Show outcome milestone descriptions above slider (always visible)
- Updates dynamically as user drags through ratings
- Example: "Expert = Can link 10+ fluid parallel turns on any groomed run while varying turn shape intentionally"

### 4.4 Returning User Experience

**Welcome Back Card (v1.1+):**
- Appears on Home screen if user returns after 24+ hours
- Shows time since last visit and current focus skill status
- "Continue where you left off" action to resume focus skill
- Dismissible with X button

**Progress Celebration:**
- Triggered when user's rating improves on any skill
- Shows confetti animation with encouraging message
- Displays "What's next" - the next milestone description to work toward
- Non-blocking - can be dismissed with tap

### 4.5 Handling Stuck Users

When users plateau on a skill:
1. **Alternative content paths** - Surface different videos/approaches
2. **Drill-down suggestions** - "Users who struggled here often needed to strengthen: [prerequisite skills]"
3. **Real-world practice prompt** - "This skill typically requires 5-10 practice sessions. Consider a lesson if stuck after repeated attempts."

---

## 5. Content Model

### 5.1 Content Types

| Type | Description | Offline? | Source |
|------|-------------|----------|--------|
| **Videos** | Instructional clips from YouTube | No (streaming) | YouTube embed (iframe) |
| **Text Tips** | Written instructions, mental cues | Yes | Original/curated |
| **Diagrams** | Body position, ski angles, movement | Yes | Original illustrations |
| **Drills** | Practice exercises with steps | Yes | Original/curated |
| **Checklists** | Pre-run sequences, warm-ups | Yes | Original |
| **Warnings** | Safety information, conditions | Yes | Original |

### 5.2 Content per Skill

Each skill should have:
- 2-3 video options (multiple sources for resilience)
- 3-5 text tips (including mental cues)
- 1-2 diagrams showing body position
- 1-2 practice drills
- Relevant safety warnings (integrated naturally)

### 5.3 YouTube Integration

- Use YouTube iframe embed API
- Accept YouTube branding and potential ads
- Multiple video sources per skill for fallback
- Link validation: Manual curation cycle with multiple fallbacks

### 5.4 Content Sourcing Strategy

**Approach:** Diverse creator mix for variety and resilience

**Primary Sources to Curate From:**
- **Stomp It Tutorials** - High-quality, consistent production, strong progression content
- **Ski School by Elate Media** - Clear instruction, good fundamentals coverage
- **Other quality channels** - Evaluate and include based on instructional quality

**Curation Criteria:**
- Clear, accurate instruction
- Good video/audio quality
- Appropriate for skill level
- No overly promotional content
- Multiple perspectives on same skill when possible

### 5.5 Content Management

**MVP Approach:**
- Content defined in bundled JSON/configuration files
- Videos linked externally (YouTube URLs)
- App updates via App Store for content changes

**Future Consideration:**
- Remote configuration for content updates without app releases
- Community submission system with approval workflow

---

## 6. Business Model

### 6.1 Freemium Structure

| Tier | Access | Price |
|------|--------|-------|
| **Free** | Beginner level (all skills) + bonus skills at assessed level* | $0 |
| **Premium** | All levels unlocked (Novice + Intermediate + Expert) | **$4.99 one-time purchase** |

**Fair Access Model:** Users who complete the skill assessment quiz receive bonus free skills at their assessed level, ensuring everyone gets useful content regardless of where they start:

| Assessed Level | Free Content |
|----------------|--------------|
| Beginner | All 5 beginner skills (default) |
| Novice | All beginner skills + 2 novice skills |
| Intermediate | All beginner skills + 2 intermediate skills |
| Expert | All beginner skills + 1 expert skill (teaser) |

This addresses a fairness concern: without bonus skills, users assessed at higher levels would have zero content at their skill level in the free tier.

**Pricing Philosophy:** Skiing is already expensive. The unlock price is intentionally set at "impulse buy" territory to maximize accessibility and adoption. No subscriptions, no recurring fees.

**Revenue Note:** After Apple's 15-30% cut, net revenue is ~$3.50-$4.25 per conversion. Goal is broad adoption over revenue maximization.

### 6.2 Premium Features
- All skill levels unlocked (Novice, Intermediate, Expert)
- Full assessment tracking across all levels
- Widget access
- (Future: Cloud sync, community features)

---

## 7. Technical Architecture

### 7.1 Platform & Framework

- **Platform:** iOS 17+ (iPhone only, no iPad initially)
- **Framework:** Native Swift/SwiftUI
- **Persistence:** Core Data for local storage
- **Future:** CloudKit for optional sync

### 7.2 Data Model

```
User
├── currentLevel: Level
├── assessments: [SkillAssessment]
├── focusSkill: Skill?
├── quizResults: QuizResult
└── preferences: UserPreferences

Skill
├── id: UUID
├── name: String
├── level: Level
├── domains: [Domain]
├── prerequisites: [Skill]
├── outcomeMilestones: [Milestone]
└── content: SkillContent

SkillContent
├── videos: [VideoReference]
├── tips: [Tip]
├── diagrams: [DiagramAsset]
├── drills: [Drill]
├── checklists: [Checklist]
└── warnings: [Warning]

SkillAssessment
├── skillId: UUID
├── context: TerrainContext
├── rating: Rating
├── date: Date
└── notes: String?
```

### 7.3 Offline Strategy

**Offline-Critical (bundled in app):**
- All skill definitions and taxonomy
- All text content (tips, drills, checklists)
- All diagram assets
- User assessment data

**Online-Required:**
- Video playback (YouTube streaming)
- (Future) Cloud sync
- (Future) Content updates

### 7.4 Key iOS Features

| Feature | Purpose |
|---------|---------|
| **Core Data** | Local persistence of user data and content |
| **WidgetKit** | Home screen widget showing current focus skill |
| **AVKit** | YouTube iframe embedding |
| **Push Notifications** | Practice reminders, tips, engagement |

---

## 8. User Interface

### 8.1 Design Principles

- **Rich & immersive** - Mountain imagery, dynamic visuals, engaging but not gamified
- **High contrast** - Readable in bright sunlight
- **Glove-friendly** - Large touch targets, one-handed operation
- **Content-first** - UI serves the content, not the other way around

### 8.2 Key Screens

1. **Home / Dashboard**
   - Welcome back card (for returning users, 24+ hours)
   - Current level progress with "Advance" action
   - Focus skill card with terrain, milestone, and mental cue
   - Suggested skills with recommendation reasons
   - Quick stats (assessments this week, level progress)

2. **Skill Browser**
   - Level-based view (default)
   - Domain category view (secondary)
   - Search/filter capabilities

3. **Skill Detail**
   - Hero section with skill name, rating, focus skill toggle
   - Inline assessment with continuous slider (drag or tap to save)
   - Prerequisites warning if not met
   - Content tabs: Videos / Tips / Drills
   - Progress celebration on rating improvement

4. **Assessment (Inline)**
   - Continuous slider with draggable thumb (🌱🌿🌲⭐)
   - Benchmark preview always visible above slider
   - Haptic feedback on drag, spring snap on release
   - Auto-saves with spinner → checkmark feedback
   - "Next goal" indicator showing path forward

5. **Profile/Progress**
   - Level progression visualization
   - Skill radar/chart by domain
   - Assessment history

### 8.3 Widget

- Small/Medium widget sizes
- Displays current focus skill
- Tap to launch directly to skill detail
- Offline-capable content display

---

## 9. Accessibility & Premium UX

### 9.1 Accessibility Requirements

- **VoiceOver** - Full support for screen reader users
- **Dynamic Type** - Text scales with system settings
- **One-handed operation** - All core features accessible with one hand
- **High contrast mode** - Enhanced visibility for outdoor use
- **Reduced motion** - Respect system motion preferences

### 9.2 Premium UX Requirements

Premium content gating must be user-friendly and never frustrating:

| Requirement | Implementation |
|-------------|----------------|
| **No Silent Failures** | Tapping locked content must show feedback (contextual upsell), never fail silently |
| **Contextual Upselling** | Show premium prompts in context (when user tries to access locked content), not just in Settings |
| **Clear Lock State** | Visual lock indicators with proper accessibility labels ("Locked premium skill") |
| **Content Value Display** | Show what's locked (e.g., "3 tips, 2 drills, 1 video") to demonstrate value |
| **Friction-Free Purchase** | One-tap purchase from any premium upsell surface |
| **Restore Purchases** | Easy access to restore previous purchases |

**Accessibility for Lock States:**
- Lock icons must have VoiceOver labels ("Locked premium skill: [skill name]")
- Accessibility hints guide users ("Double tap to view unlock options")
- Premium upsell modals must be fully navigable with VoiceOver

---

## 10. Analytics & Optimization

### 10.1 Key Metrics to Track

- User progression through levels
- Skill completion rates
- Video watch completion
- Assessment frequency
- Session duration by context (pre/during/post)
- Drop-off points in onboarding
- Premium conversion rate

### 10.2 App Store Optimization

- **App Name:** Turn Lab
- **Subtitle:** "Master Your Ski Progression"
- **Keywords:** ski instruction, learn to ski, ski lessons, skiing tips, ski progression, ski technique, ski drills
- **Screenshots:** Immersive mountain imagery, skill progression, on-mountain UI
- **Video preview:** Demonstrate the progression and on-mountain experience

---

## 11. Future Considerations

Features explicitly deferred from MVP:

| Feature | Notes |
|---------|-------|
| Community submissions | Users suggest content, approval workflow |
| Social sharing | Share achievements to social media |
| In-app community | Forums, comments, discussion |
| CloudKit sync | Sync progress across devices |
| iPad support | Optimized iPad interface |
| Multiple languages | Localization beyond English |
| Session logging | Track actual ski days/runs |
| Instructor mode | Tools for coaches to assign content |
| Hybrid ad-to-preview | Watch a rewarded ad to temporarily unlock skill preview before purchase decision |
| Content previews | Allow browsing locked skill details with teaser content (tip titles, drill names) |

---

## 12. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| YouTube content removal | Broken video links | Multiple video sources per skill, manual curation cycle |
| Content quality varies | Poor user experience | Strict curation standards, user feedback mechanism |
| Competition from free YouTube | Low adoption | Focus on structure, tracking, on-mountain utility |
| Offline complexity | Development effort | Clear separation of online/offline content |
| Instructional accuracy | Credibility | Research-based approach, no official certification claims |

---

## 13. Resolved Decisions

| Question | Decision |
|----------|----------|
| **App naming** | Turn Lab |
| **Premium pricing** | $4.99 one-time freemium unlock |
| **Content sourcing** | Diverse creator mix (Stomp It, Ski School by Elate, others) |
| **PSIA accuracy** | Informed by PSIA methodology, no official alignment claimed |
| **Beta testing** | Minimal testing - launch and iterate based on App Store feedback |

## 14. Launch Strategy

### 14.1 Testing Approach
- **Minimal formal beta testing** - Trust the build quality
- **Launch and iterate** - Use App Store reviews and feedback for improvements
- **Analytics-driven iteration** - Let data guide post-launch updates

### 14.2 Discovery Strategy
- **App Store Optimization** is primary discovery channel
- **Ski community engagement** - r/skiing, ski forums, Facebook groups
- **Seasonal timing** - Target visibility during Northern Hemisphere ski season
- **Word of mouth** - Accessible pricing encourages sharing

---

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| PSIA | Professional Ski Instructors of America |
| AASI | American Association of Snowboard Instructors |
| Wedge | Snowplow position with ski tips together |
| Christie | Turn where skis become parallel during the turn |
| Carving | Turning on ski edges without skidding |
| Angulation | Body angles created to maintain edge contact |

---

## Appendix B: Content Examples

### Sample Skill: Parallel Turns (Intermediate)

**Outcome Milestones:**
- Needs Work: "Skis frequently cross or wedge during turns"
- Developing: "Can make parallel turns on easy terrain with concentration"
- Confident: "Links parallel turns naturally on blue runs in varied conditions"
- Mastered: "Controls turn shape and speed with parallel technique on any groomed terrain"

**Contextual Assessments:**
- On groomed blue runs
- On groomed black runs
- In variable/crud snow
- On steeper terrain (>25°)

**Content Package:**
- Video 1: "Parallel Turn Fundamentals" (primary)
- Video 2: "Common Parallel Turn Mistakes" (alternative)
- Video 3: "Parallel Turns on Steeper Terrain" (contextual)
- Tip: "Imagine your feet are on a lazy Susan rotating together"
- Drill: "Traverse and turn practice - 10 turns each direction"
- Diagram: Weight distribution through parallel turn phases
- Warning: "On icy conditions, focus on edge angle before turn initiation"
