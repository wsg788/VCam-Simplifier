# VCam Simplifier

**A production-ready Android application that transforms the powerful but notoriously complex `android_virtual_cam` LSPosed module into a safe, intuitive, "dummy-proof" utility.**

[![License](https://img.shields.io/badge/License-Custom%20-%20red)](LICENSE)
[![Android](https://img.shields.io/badge/Android-8.0%2B-green)](https://developer.android.com/)
[![Root](https://img.shields.io/badge/Root-Magisk%20%2B%20Zygisk%20%2B%20LSPosed-orange)](https://github.com/topjohnwu/Magisk)

---

## Project Vision & Thesis

The `android_virtual_cam` LSPosed module is an incredibly powerful tool for virtual camera spoofing on Android. It hooks the legacy Camera1 API (via `SurfaceTexture` substitution), allowing apps to receive a video feed (`virtual.mp4`) or static image (`1000.bmp`) instead of the real camera. It supports advanced controls through flag files (`disable.jpg`, `no-silent.jpg`, etc.) placed in carefully chosen directories (global `/sdcard/DCIM/Camera1/` or per-app private paths like `/data/data/<package>/files/Camera1/`).

However, its power comes at the cost of extreme complexity and a steep learning curve:

- Dozens of manual steps involving `adb`, root file managers, precise resolution matching, FFmpeg transcoding on a PC, pushing files, enabling the module in LSPosed Manager, configuring scopes for target apps, creating/deleting flag files, handling path differences across apps/ROMs, and troubleshooting silent failures.

- High failure rate due to path mismatches, resolution issues, permission problems, module not being active, LSPosed CLI nuances, and lack of feedback.

**VCam Simplifier** solves this by providing a complete, on-device, root-aware automation layer:

- **Guided First-Run Setup** that verifies prerequisites (root via libsu, Magisk, Zygisk, LSPosed), installs the bundled `vcam.apk` module using `pm install` + root, automates enabling and scoping via the official LSPosed CLI (`/data/adb/lspd/bin/cli`), and prompts for the one-time reboot.

- **Clean Modern UI** (Jetpack Compose + Material 3) with system integrity dashboard, searchable target app selector (with live scope updates via CLI), Virtual Media Hub featuring on-device FFmpeg (bundled arm64-v8a binary) for transcoding/rotation/flip + automatic smart placement of `virtual.mp4` (and `1000.bmp`), and master toggles that manage flag files safely.

- **Privileged Repository Pattern** using `libsu` (com.topjohnwu.libsu) for *all* root operations — no raw `Runtime.exec("su")` ever. Full error handling, logging, pre-flight checks, and graceful degradation.

- **AccessibilityService + FFmpeg strategy** for automatic resolution detection (parsing toasts) and on-device media processing, eliminating the need for a desktop PC in the workflow.

- **Failure Mode Elimination**: Directly maps every documented manual pain point and silent failure to automated, safe solutions with contextual guidance.

The result: A "set it and forget it" experience for power users and developers who want virtual camera capabilities without the constant frustration and risk of bricking their setup.

**This project follows the complete architectural blueprint, implementation guide, and technical specifications provided in the reference materials (Android Virtual Cam App Development Outline, On-Device Development guide, module behavior docs, etc.).**

## ⚠️ Critical Warnings — Read Carefully

### Rooting & Security Risks
- This application **requires a fully rooted device** with Magisk, Zygisk, and LSPosed (or Shamiko + Zygisk) active and properly configured.
- Rooting your device **voids the manufacturer's warranty** and introduces significant security risks if not done carefully.
- Always perform a full backup (including bootloader unlock if applicable) before proceeding.
- The app uses privileged root access via libsu. All operations are logged and designed with safety checks.

### Ethical and Legal Responsibility
**This tool is provided strictly for:**
- Legitimate development and testing purposes
- Personal privacy enhancement on devices you fully own and control
- Educational exploration of Android internals and hooking techniques

**You MUST NOT use this tool for:**
- Deception, social engineering, catfishing, or impersonation
- Unauthorized recording or surveillance of others
- Bypassing authentication, security mechanisms, or terms of service of any app/service
- Any activity that violates local laws, app policies (Google, banking/fintech apps are particularly sensitive), or ethical standards
- Harm to others or violation of privacy rights

**Misuse is your sole responsibility.** The developers and contributors explicitly disclaim any liability for illegal, unethical, or harmful use. By installing or using this software, you acknowledge that you understand these restrictions and will comply with them. If you cannot agree, do not use this application.

### LSPosed Module Specifics
- The bundled `android_virtual_cam` module primarily hooks the **deprecated Camera1 API**. Many modern apps use Camera2 or other methods and will not be affected.
- Behavior depends on exact file placement, resolution matching, and flag files. The app includes smart detection and pre-flight validation to minimize issues.
- Some apps may detect virtual camera usage or modified environments and may refuse to function or ban accounts.
- Always test in isolated environments first.

## Features (Implemented per Blueprint)

- **First-Run Setup Wizard**: One-time automated installation and configuration.
- **System Status Dashboard**: Real-time checks for root, Magisk, Zygisk, LSPosed presence, module installation status, LSPosed CLI usability, and recommended actions.
- **Target App Manager**: Searchable list of user-installed apps. Toggle to add/remove from LSPosed scope for the virtual_cam module using official CLI + root. No need to open LSPosed Manager repeatedly.
- **Virtual Media Hub**:
  - File picker for source video/image.
  - Automatic or assisted resolution detection (AccessibilityService parsing camera app toasts + FFprobe).
  - One-tap on-device FFmpeg processing (transcode to H.264 baseline, rotate, flip, resize to exact target resolution, add audio if needed).
  - Intelligent path resolution: Detects global `DCIM/Camera1` vs per-app private directories.
  - Automatic placement of `virtual.mp4` (and optional `1000.bmp` for static).
  - Master enable/disable and advanced toggles that safely create/delete control flag files (`disable.jpg`, `no-silent.jpg`, etc.).
- **Pre-flight Validation & Troubleshooting**: Before any change, checks for common failure modes and provides clear, actionable guidance with logs.
- **Diagnostics Export**: Share detailed logs, current configuration, module status for debugging.
- **Minimalist "Dummy-Proof" UI**: After initial setup, a clean, focused interface that hides complexity while exposing power when needed. Material You theming.

## High-Level Architecture

```
UI (Jetpack Compose + Material 3)
          ↓
ViewModels + UseCases
          ↓
Privileged Repositories (libsu-backed)
   - RootRepository (shell commands, file ops, pm install)
   - LSPosedRepository (CLI interactions for enable/scope)
   - MediaRepository (FFmpeg wrapper, path detection, file placement)
   - SettingsRepository (flag files, preferences)
          ↓
Native/Root Layer (libsu Shell, bundled FFmpeg binary, AccessibilityService)
```

**Core Principles**:
- **Safety First**: Every root operation is wrapped, validated, logged, and reversible where possible. Pre-flight checks prevent known bad states.
- **On-Device Everything**: Primary development and media processing happen on the device itself (Termux + Acode rapid cycle + bundled FFmpeg).
- **Repository Pattern + Coroutines/Flow**: Clean, testable, observable state.
- **Graceful Degradation**: If LSPosed CLI is not enabled in LSPosed Manager settings, guide user once; otherwise full automation.

**Key Technologies**:
- Kotlin + Jetpack Compose + ViewModel + Hilt (or Koin)
- libsu 5.x (core, io, service)
- Coroutines + StateFlow
- Bundled arm64-v8a FFmpeg static binary + custom Kotlin/Shell wrapper with progress reporting
- LSPosed official CLI automation
- AccessibilityService for toast parsing / resolution hints
- Scoped storage + root fallbacks for file operations

## Recommended Project Structure

```
VCam-Simplifier/
├── app/                          # Main Android application (Kotlin/Compose)
│   ├── src/main/java/com/wsg/vcamsimplifier/
│   │   ├── data/
│   │   │   ├── repository/     # Privileged*Repository classes
│   │   │   ├── local/          # DAOs, preferences, file helpers
│   │   ├── domain/
│   │   │   ├── usecase/
│   │   │   ├── model/
│   │   ├── di/               # Dependency injection
│   │   ├── service/          # MyAccessibilityService, FirstRunSetupService
│   │   ├── ui/
│   │   │   ├── screen/
│   │   │   ├── component/
│   │   ├── utils/
│   │   │   ├── FFmpegUtils.kt
│   │   │   ├── PathResolver.kt
│   │   │   ├── FlagManager.kt
│   │   │   ├── Logger.kt
│   │   ├── MainActivity.kt
│   │   ├── VCamApplication.kt
│   ├── assets/
│   │   │   ├── vcam.apk                  # Bundled LSPosed module
│   │   │   ├── ffmpeg                  # arm64-v8a static binary (executable)
│   │   ├── res/
│   ├── build.gradle.kts
│   ├── proguard-rules.pro
├── magisk-module/              # (Optional) Unified flashable Magisk module
│   │   ├── module.prop
│   │   ├── customize.sh
│   │   ├── system/app/ or common/
│   │   ├── META-INF/
├── docs/                       # Reference blueprints, CLI command reference, failure modes catalog
├── gradle/
├── build.gradle.kts (root)
├── settings.gradle.kts
├── .gitignore
├── README.md
├── LICENSE
├── gradle.properties
```

## Build & Development Workflow

### Primary: On-Device Development (Termux + Acode) — Recommended

Follow the detailed methodology in the attached **"On-Device Development of a Root-Aware Android Utility.pdf"** and **"Android Virtual Cam App Development Outline.pdf"**.

Typical rapid cycle:

1. Install Termux (F-Droid recommended), Acode editor, and required packages (`pkg install git openjdk-17 wget` etc. as per guide).
2. `git clone https://github.com/wsg788/VCam-Simplifier.git`
3. `cd VCam-Simplifier`
4. Edit code in Acode (or any editor that supports Kotlin).
5. In Termux: `./gradlew clean installDebug` (configure signing if needed; debug keystore works for testing).
6. The app installs/updates on-device. Since rooted, you can immediately test root features.
7. Use `adb logcat` (or Termux `logcat` wrapper) filtered for your package for excellent logging.
8. Iterate quickly — no need for desktop Android Studio for most changes.

**Note on Gradle in Termux**: May require setting `JAVA_HOME`, increasing memory (`-Xmx4g` or via gradle.properties), and handling Android SDK if not using prebuilt.

### Alternative: Desktop Android Studio

1. Clone repo.
2. Open in latest Android Studio (Giraffe+ or newer recommended).
3. Sync, build debug APK.
4. `adb install app/build/outputs/apk/debug/app-debug.apk`
5. For full testing, use a rooted test device with LSPosed active. Use `adb logcat` for diagnostics.

**Important**: The app's `assets/` will contain the `vcam.apk` (rename if needed to match package) and the FFmpeg binary. You must obtain/place the correct arm64 static FFmpeg (statically linked, recent version with libx264 etc. for video).

## Current Development Phase

**Phase 0 Complete**: Repository created, initial professional README pushed, high-level architecture defined.

**Next: Phase 1** — Project scaffolding (empty Compose app), libsu integration, root detection & prerequisite status screen, basic logging setup.

See detailed Phase 1 outline below (or in conversation history).

## Roadmap

- [x] GitHub repo + README
- [ ] Phase 1: Scaffolding + libsu + prereq checks
- [ ] Phase 2: First-Run Setup automation (module install, LSPosed CLI, reboot)
- [ ] Phase 3: Target App Selector + scope management
- [ ] Phase 4: Virtual Media Hub (picker, FFmpeg, smart placement, flags)
- [ ] Phase 5: AccessibilityService, full error handling, diagnostics
- [ ] Phase 6: Polish, testing across devices/ROMs, optional unified Magisk module ZIP
- [ ] v1.0 release

## Getting Help / Reporting Issues

- Open a GitHub Issue with:
  - Device model + Android version + ROM
  - Magisk version + Zygisk status
  - LSPosed version
  - Exact steps to reproduce + `adb logcat` excerpt (filter by package)
  - Screenshots of UI or error
- Be patient; this is complex root territory.

## Credits

- Original `android_virtual_cam` LSPosed module author(s)
- libsu / Magisk by topjohnwu
- LSPosed framework and CLI developers
- FFmpeg team
- Android modding community for reverse engineering Camera1 behavior and documenting failure modes
- Reference materials: Android Virtual Cam App Development Outline.pdf, On-Device Development..., module technical explanation, etc.

**Use responsibly. Power is nothing without control and ethics.**

---

*This project is experimental and provided as-is for advanced users.*
