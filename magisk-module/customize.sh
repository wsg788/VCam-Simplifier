#!/system/bin/sh
# VCam Simplifier - Unified Magisk Module
# Installs android_virtual_cam LSPosed module + VCam Simplifier APK
# Creates default Camera1 directory and prepares the environment

MODDIR=${0%/*}

ui_print "======================================"
ui_print "   VCam Simplifier - Magisk Module"
ui_print "   Version: $(grep_prop version $MODDIR/module.prop)"
ui_print "======================================"
ui_print ""

# Function to print with timestamp (optional)
ui_print "[INFO] Starting installation..."

# 1. Install the LSPosed module (android_virtual_cam)
if [ -f "$MODDIR/vcam.apk" ]; then
    ui_print "[1/4] Installing android_virtual_cam LSPosed module..."
    pm install -r "$MODDIR/vcam.apk" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        ui_print "      ✓ LSPosed module installed successfully"
    else
        ui_print "      ! Failed to install vcam.apk via pm. It may already be installed or needs manual step."
    fi
else
    ui_print "[1/4] WARNING: vcam.apk not found in module package."
    ui_print "      Please ensure vcam.apk is placed in the magisk-module/ folder before building the ZIP."
fi

# 2. Install the VCam Simplifier manager app
if [ -f "$MODDIR/VCamSimplifier.apk" ]; then
    ui_print "[2/4] Installing VCam Simplifier manager app..."
    pm install -r "$MODDIR/VCamSimplifier.apk" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        ui_print "      ✓ VCam Simplifier app installed"
    else
        ui_print "      ! pm install failed for VCamSimplifier.apk"
    fi
else
    ui_print "[2/4] WARNING: VCamSimplifier.apk not found. Build the app first and place the APK here."
fi

# 3. Create default global Camera1 directory (used by many apps)
ui_print "[3/4] Creating default virtual camera directory..."
mkdir -p /sdcard/DCIM/Camera1
chmod 777 /sdcard/DCIM/Camera1
chown media_rw:media_rw /sdcard/DCIM/Camera1 2>/dev/null || true
ui_print "      ✓ /sdcard/DCIM/Camera1/ ready (global path)"

# Optional: Create per-app example directories or initial flag files
# touch /sdcard/DCIM/Camera1/disable.jpg   # master disable (uncomment if desired as default)
# touch /sdcard/DCIM/Camera1/no-silent.jpg

# 4. Post-install guidance
ui_print "[4/4] Installation complete."
ui_print ""
ui_print "IMPORTANT:"
ui_print "  - Reboot your device now."
ui_print "  - After reboot, open the 'VCam Simplifier' app."
ui_print "  - The app will detect the Magisk installation and guide you through:"
ui_print "      * Verifying LSPosed module status"
ui_print "      * Enabling the module via CLI (if not already active)"
ui_print "      * Selecting target apps (scopes)"
ui_print "      * Adding your first virtual.mp4 via the Media Hub"
ui_print ""
ui_print "Requirements: Magisk + Zygisk + LSPosed must already be installed and active."
ui_print "This module only automates installation of the components."
ui_print ""
ui_print "For ethical use only: development, testing, and personal privacy on devices you own."
ui_print "======================================"

# Note: Full automation of LSPosed module enabling often requires a reboot
# and the VCam Simplifier app (which has root + CLI access) to finish setup.
# This is by design for safety and compatibility across ROMs.