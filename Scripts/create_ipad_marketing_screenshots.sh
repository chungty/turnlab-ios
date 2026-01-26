#!/bin/bash
# Create marketing overlays for iPad screenshots
# Matches the iPhone screenshot style

set -e

SCREENSHOTS_DIR="./fastlane/screenshots/en-US/ipad"
OUTPUT_WIDTH=2048
OUTPUT_HEIGHT=2732

# Process each screenshot
process_screenshot() {
    local key="$1"
    local title="$2"
    local subtitle="$3"

    RAW_FILE="${SCREENSHOTS_DIR}/${key}_raw.png"
    OUTPUT_FILE="${SCREENSHOTS_DIR}/${key}.png"

    if [ ! -f "$RAW_FILE" ]; then
        echo "Skipping $key - raw file not found"
        return
    fi

    echo "Processing: $key"
    echo "  Title: $title"
    echo "  Subtitle: $subtitle"

    # Create dark blue gradient background
    magick -size ${OUTPUT_WIDTH}x${OUTPUT_HEIGHT} \
        gradient:'#1a365d-#0f172a' \
        -rotate 180 \
        /tmp/background.png

    # Calculate screenshot dimensions (scale to fit with padding)
    # Leave space for header text (about 200px at top)
    SCREENSHOT_MAX_HEIGHT=$((OUTPUT_HEIGHT - 280))
    SCREENSHOT_MAX_WIDTH=$((OUTPUT_WIDTH - 80))

    # Resize screenshot maintaining aspect ratio and add rounded corners
    magick "$RAW_FILE" \
        -resize ${SCREENSHOT_MAX_WIDTH}x${SCREENSHOT_MAX_HEIGHT} \
        \( +clone -alpha extract \
           -draw "fill black polygon 0,0 0,40 40,0 fill white circle 40,40 40,0" \
           \( +clone -flip \) -compose Multiply -composite \
           \( +clone -flop \) -compose Multiply -composite \
        \) -alpha off -compose CopyOpacity -composite \
        /tmp/screenshot_rounded.png

    # Get actual screenshot dimensions after resize
    SCREENSHOT_WIDTH=$(magick identify -format '%w' /tmp/screenshot_rounded.png)
    SCREENSHOT_HEIGHT=$(magick identify -format '%h' /tmp/screenshot_rounded.png)

    # Calculate position to center screenshot
    X_OFFSET=$(( (OUTPUT_WIDTH - SCREENSHOT_WIDTH) / 2 ))
    Y_OFFSET=$(( 260 + (SCREENSHOT_MAX_HEIGHT - SCREENSHOT_HEIGHT) / 2 ))

    # Composite everything together
    magick /tmp/background.png \
        -gravity North \
        -font "Helvetica-Bold" -pointsize 72 -fill white \
        -annotate +0+60 "$title" \
        -font "Helvetica" -pointsize 36 -fill '#94a3b8' \
        -annotate +0+150 "$subtitle" \
        /tmp/screenshot_rounded.png -geometry +${X_OFFSET}+${Y_OFFSET} -composite \
        "$OUTPUT_FILE"

    echo "  Created: $OUTPUT_FILE"
}

echo "=== Creating iPad Marketing Screenshots ==="
echo ""

process_screenshot "01_home_dashboard" "Master Every Turn" "Structured progression from beginner to expert"
process_screenshot "02_skills_browser" "20 Skills. 5 Domains." "PSIA-based curriculum for real improvement"
process_screenshot "03_skill_tips" "Mental Cues That Stick" "Learn on the lift, apply on the slopes"
process_screenshot "04_assessment" "Track Real Progress" "Outcome-based milestones you can see"
process_screenshot "05_profile" "Know Your Strengths" "Visual progress across all skill domains"
process_screenshot "06_settings" "Your Settings" "Customize your experience"
process_screenshot "07_premium_purchase" "Unlock Your Potential" "Access all skill levels with Premium"

# Cleanup
rm -f /tmp/background.png /tmp/screenshot_rounded.png

echo ""
echo "=== Done! ==="
echo "Marketing screenshots created in: $SCREENSHOTS_DIR"

# Show dimensions
echo ""
echo "Screenshot dimensions:"
for f in "$SCREENSHOTS_DIR"/*.png; do
    if [[ ! "$f" =~ "_raw" ]]; then
        echo "  $(basename "$f"): $(magick identify -format '%wx%h' "$f")"
    fi
done
