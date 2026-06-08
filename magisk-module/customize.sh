#!/system/bin/sh
# VCam Simplifier - Pure Magisk + Zygisk Virtual Camera Solution
# No LSPosed dependency

MODDIR=${0%/*}

ui_print "======================================"
ui_print "   VCam Simplifier"
ui_print "   Pure Magisk/Zygisk Virtual Camera"
ui_print "======================================"
ui_print ""

ui_print "[1/3] Installing VCam Simplifier companion app..."
if [ -f "$MODDIR/VCamSimplifier.apk" ]; then
    pm install -r "$MODDIR/VCamSimplifier.apk" > /dev/null 2>&1
    ui_print "      ✓ Companion app installed"
else
    ui_print "      ! VCamSimplifier.apk not found in module. Build the APK first."
fi

ui_print "[2/3] Setting up virtual camera directories..."
mkdir -p /sdcard/DCIM/Camera1
chmod 777 /sdcard/DCIM/Camera1
ui_print "      ✓ /sdcard/DCIM/Camera1/ ready"

# Create dedicated working directory for the module
mkdir -p /data/adb/vcam
chmod 777 /data/adb/vcam
ui_print "      ✓ /data/adb/vcam/ working directory ready"

ui_print "[3/3] Zygisk module prepared."
ui_print ""
ui_print "Installation complete."
ui_print "Please reboot your device."
ui_print "After reboot, open the VCam Simplifier app to:"
ui_print "  - Add your video (with on-device FFmpeg processing)"
ui_print "  - Enable/disable spoofing"
ui_print "  - Manage advanced settings"
ui_print ""
ui_print "The Zygisk component will handle camera spoofing."
ui_print "No LSPosed required."
ui_print "======================================"