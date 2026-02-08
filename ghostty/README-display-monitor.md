# Ghostty Display Monitor Setup

## What This Does

Automatically toggles `font-thicken` based on your active display:
- **Built-in MacBook screen**: `font-thicken = false` (thinner fonts)
- **External monitor**: `font-thicken = true` (thicker, more readable fonts)

## Files Created

1. **`display-monitor.sh`** - Script that detects displays and updates config
2. **`~/Library/LaunchAgents/com.ghostty.displaymonitor.plist`** - LaunchAgent that runs the script automatically
3. **Log files** in `~/.config/ghostty/`:
   - `display-monitor.log` - Main activity log
   - `display-monitor-stdout.log` - Standard output
   - `display-monitor-stderr.log` - Error output

## How It Works

1. The LaunchAgent monitors system display changes
2. When a display change is detected, it runs `display-monitor.sh`
3. The script checks if an external monitor is connected
4. It updates your Ghostty config and reloads it automatically

## Manual Controls

### Check Status
```bash
cat ~/.config/ghostty/display-monitor.log
```

### Run Manually
```bash
~/.config/ghostty/display-monitor.sh
```

### Stop Monitoring
```bash
launchctl unload ~/Library/LaunchAgents/com.ghostty.displaymonitor.plist
```

### Start Monitoring
```bash
launchctl load ~/Library/LaunchAgents/com.ghostty.displaymonitor.plist
```

### Restart Monitoring
```bash
launchctl unload ~/Library/LaunchAgents/com.ghostty.displaymonitor.plist
launchctl load ~/Library/LaunchAgents/com.ghostty.displaymonitor.plist
```

## Troubleshooting

### Check if LaunchAgent is running
```bash
launchctl list | grep ghostty
```

### View logs
```bash
tail -f ~/.config/ghostty/display-monitor.log
```

### Test display detection
```bash
system_profiler SPDisplaysDataType | grep "Display Type"
```

## Customization

Edit `display-monitor.sh` to customize:
- Font thickening strength
- Detection logic
- Additional settings to toggle

## Notes

- The config reload uses your existing `cmd+r` keybind
- Changes apply immediately when displays are connected/disconnected
- Logs are appended (not overwritten) for debugging
