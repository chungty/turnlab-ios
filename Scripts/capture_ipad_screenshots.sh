#!/bin/bash
# Capture native iPad screenshots for App Store submission
#
# Required sizes for App Store Connect:
# - 12.9" iPad Pro: 2048 x 2732 pixels
# - 11" iPad Pro: 1668 x 2388 pixels (optional, can use 12.9" for all)

set -e

SCREENSHOTS_DIR="./fastlane/screenshots/en-US/ipad"
SIMULATOR_NAME="iPad Pro 13-inch (M4)"

echo "=== iPad Screenshot Capture Script ==="
echo ""

# Boot the simulator
echo "1. Booting iPad simulator: $SIMULATOR_NAME"
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || echo "   (Simulator already booted or starting...)"
sleep 3

# Open Simulator app
echo "2. Opening Simulator app..."
open -a Simulator

# Wait for simulator to be ready
echo "3. Waiting for simulator to be ready..."
sleep 5

# Build and install the app
echo "4. Building app for iPad..."
xcodebuild -project TurnLab.xcodeproj \
    -scheme TurnLab \
    -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
    -derivedDataPath ./build/DerivedData \
    build 2>&1 | grep -E "(BUILD SUCCEEDED|BUILD FAILED|error:)" || true

# Install the app
echo "5. Installing app on simulator..."
APP_PATH=$(find ./build/DerivedData -name "TurnLab.app" -type d | head -1)
if [ -n "$APP_PATH" ]; then
    xcrun simctl install booted "$APP_PATH"
    echo "   App installed successfully"
else
    echo "   ERROR: Could not find built app. Please build manually first."
    exit 1
fi

# Launch the app
echo "6. Launching app..."
xcrun simctl launch booted com.turnlab.app

echo ""
echo "=== Manual Screenshot Instructions ==="
echo ""
echo "The app is now running on iPad simulator. Take screenshots manually:"
echo ""
echo "1. Navigate to each screen in the app"
echo "2. Press Cmd+S to save screenshot (or File > Save Screen)"
echo "3. Save to: $SCREENSHOTS_DIR/"
echo ""
echo "Screens to capture:"
echo "  - 01_home_dashboard.png (Home screen)"
echo "  - 02_skills_browser.png (Skills tab)"
echo "  - 03_skill_tips.png (Skill detail with tips)"
echo "  - 04_assessment.png (Assessment screen)"
echo "  - 05_profile.png (Profile tab)"
echo "  - 06_settings.png (Settings screen)"
echo ""
echo "After capturing raw screenshots, you'll need to add marketing overlays"
echo "matching the style of the iPhone screenshots."
echo ""
echo "Press Enter when done to shut down the simulator..."
read

# Shutdown simulator
echo "Shutting down simulator..."
xcrun simctl shutdown "$SIMULATOR_NAME"

echo "Done! Check $SCREENSHOTS_DIR for your screenshots."
