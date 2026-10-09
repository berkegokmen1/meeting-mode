<p align="center"><img src="docs/images/app-icon.png" width="96" alt="Meeting Mode icon"></p>
<h1 align="center">Meeting Mode</h1>
<p align="center">One click to a clean, black desktop. One click back.</p>

Meeting Mode is a standalone native macOS menu-bar app built with Swift and AppKit. It temporarily covers desktop icons and widgets with black windows behind your applications, without modifying wallpaper or Finder preferences.

## Use

1. Install the `.pkg` into Applications and open **Meeting Mode**.
2. Click the camera icon in the top menu bar.
3. Leave **Hide desktop icons and widgets** checked and select **Start Meeting Mode**.
4. Select **End Meeting Mode** to remove the covers. **Quit** also ends the session.

The camera fills in while active, and the menu shows elapsed minutes. **Open at login** is optional and disabled by default. Covers let mouse clicks through so macOS can handle clicking the desktop after a Show Desktop hot corner.

## Build and test

Requires Apple Silicon, macOS 13 or later, and Xcode Command Line Tools. No third-party runtime dependencies.

```sh
./scripts/test.sh
./scripts/build.sh
```

The build creates `build/release/Meeting Mode.app` and `build/MeetingMode-0.1.3.pkg`. The installer installs into `/Applications`. Quit any running copy before updating, then reopen the installed copy. Avoid running both a build copy and the installed copy simultaneously.

The app is ad-hoc signed; the installer is unsigned and not notarized. Developer ID signing and notarization are needed for normal external distribution.

## Permissions and privacy

No Accessibility, Screen Recording, microphone or camera access. No analytics, networking, AppleScript, Shortcuts or external commands at runtime. Optional login registration uses Apple's ServiceManagement API. macOS may require login-item approval and the installer may request an administrator password.

This app does not control Do Not Disturb or block notifications. Use Control Center for Focus. It has no connection to Recent Screenshots.

## Restoration and limitations

An atomic recovery journal is saved before creating covers. Start/End transitions reject repeated clicks while busy. End removes covers before clearing the journal. Normal Quit attempts restoration and cancels quitting if cleanup fails. After a crash or force-quit, macOS destroys the cover windows; the next launch offers to clear the saved session.

Journal location: `~/Library/Application Support/Meeting Mode/session.json`. Actual wallpaper, desktop icon preferences, widget configuration and desktop files remain untouched. No Finder or Dock restart. The original desktop reappears when covers close.

Covers are visual only: the hidden items remain interactive because clicks pass through. Mission Control, Show Desktop, fullscreen Spaces and screen-sharing behavior can expose desktop contents. This is not a security boundary. No restoration can be promised while the app is no longer running.

## Project layout

```text
Sources/          AppKit menu, desktop covers and recovery journal
Tests/            Isolated journal fixtures
scripts/          Build, installer, icon generation and tests
docs/             Validation notes and images
```

## Validation

Journal fixtures check round-trip crash recovery, repeated saves, repeated clearing, corrupt state and failed writes. Build and installer generation pass. A single inactive-process sample on macOS 26.6.2 measured 0.0% CPU and approximately 37.7 MiB RSS; this is not a sustained profile.

See [manual validation checklist](docs/VALIDATION.md) for outstanding desktop and installer checks. App UI capture is currently unavailable through the automation tool, so this README does not include fabricated screenshots.
