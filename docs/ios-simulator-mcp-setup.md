# iOS Simulator MCP Setup for TurnLab

## Status: READY TO USE

After restarting Claude Code, the `ios-simulator` MCP server will be available.

## What Was Installed

1. **Facebook IDB Companion** (v1.1.8)
   - Location: `/usr/local/bin/idb_companion`
   - Installed via: `brew install idb-companion`

2. **fb-idb Python Client** (v1.1.7)
   - Location: `/Library/Frameworks/Python.framework/Versions/3.11/bin/idb`
   - Installed via: `pip3 install fb-idb`

3. **ios-simulator-mcp** (MCP Server)
   - Config location: `~/.claude.json`
   - Command: `npx ios-simulator-mcp`

## Available Tools After Restart

| Tool | Description |
|------|-------------|
| `ios_simulator_screenshot` | Capture simulator screen |
| `ios_simulator_tap` | Tap at x,y coordinates |
| `ios_simulator_swipe` | Swipe gestures |
| `ios_simulator_input_text` | Type text into fields |
| `ios_simulator_describe_ui` | Get accessibility tree |
| `ios_simulator_get_element_at` | Inspect element at coordinates |
| `ios_simulator_launch_app` | Launch app by bundle ID |
| `ios_simulator_record_video` | Record screen sessions |

## How to Start Bug Hunting

### 1. Restart Claude Code (required to load MCP server)

### 2. Boot the simulator and run TurnLab:
```bash
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator
xcrun simctl launch booted com.turnlab.app
```

### 3. Ask Claude to diagnose:
```
Take a screenshot of the simulator and describe what you see.
Then use the accessibility tree to identify any UI issues.
```

### 4. Use Ralph Wiggum loop:
```
/ralph-loop
```
This will iterate: screenshot -> analyze -> fix -> rebuild -> verify

## TurnLab App Details

- **Bundle ID:** `com.turnlab.app`
- **Project Path:** `/Users/chungty/Projects/skiprog`
- **Build Command:**
  ```bash
  xcodebuild -project TurnLab.xcodeproj -scheme TurnLab \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
  ```

## Troubleshooting

If MCP tools aren't available after restart:
```bash
# Verify idb is working
idb list-targets

# Check MCP config
cat ~/.claude.json | grep -A5 "ios-simulator"

# Reinstall MCP if needed
claude mcp remove ios-simulator
claude mcp add ios-simulator -- npx ios-simulator-mcp
```

## Quick Reference Commands

```bash
# List available simulators
xcrun simctl list devices available

# Boot specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Install app on simulator
xcrun simctl install booted ./build/Build/Products/Debug-iphonesimulator/TurnLab.app

# Launch app
xcrun simctl launch booted com.turnlab.app

# Take screenshot (fallback if MCP not working)
xcrun simctl io booted screenshot /tmp/screen.png
```
