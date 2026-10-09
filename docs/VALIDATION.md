# Manual validation

These checks remain unverified unless recorded below.

- [ ] Install package; launch only the Applications copy.
- [ ] Verify empty/filled camera icon and elapsed time.
- [ ] Start twice and End twice; verify a stable final state.
- [ ] Check icons and widgets are visually covered on each display.
- [ ] Show Desktop via bottom-left hot corner; click desktop to restore windows.
- [ ] Check Mission Control, Spaces, fullscreen apps and screen sharing.
- [ ] Connect/disconnect a display while active.
- [ ] Quit while active and confirm covers disappear.
- [ ] Force-quit while active, relaunch and accept recovery.
- [ ] Make recovery storage unwritable in an isolated test account; verify errors and recoverability.
- [ ] Enable/disable Open at login and verify after login.

Automated journal fixtures and installer build passed on macOS 26.6.2. UI automation timed out accessing the menu-bar app, so screenshots and visual checks are not marked complete.
