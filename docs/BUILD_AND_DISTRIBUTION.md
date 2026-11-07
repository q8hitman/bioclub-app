# Build and distribution

## On a Mac
1. Use Xcode 26.6, the toolchain exercised by this delivery's macOS CI, with an installed iOS simulator runtime (deployment target remains iOS 17). Older Xcode releases have not been validated against the WebKit concurrency annotations.
2. Open `BSCKU.xcodeproj`. Select the shared `BSCKU` scheme and an installed iPhone or iPad simulator.
3. Run Product → Build, then Product → Test. No package manager or external dependency is required.
4. For device builds, set your Apple development team and a registered bundle identifier in target settings. Do not put signing credentials in the repository.

Command line (replace the simulator name with one listed by `xcodebuild -showdestinations -scheme BSCKU`):
```sh
xcodebuild -list -project BSCKU.xcodeproj
xcodebuild -project BSCKU.xcodeproj -scheme BSCKU -destination 'platform=iOS Simulator,name=iPhone 16' test CODE_SIGNING_ALLOWED=NO
```

After adding/removing Swift files, run `python3 scripts/generate_project.py`, then `python3 scripts/validate_project.py`. The generator overwrites project settings; keep signing changes local or update its settings intentionally.

## Release gate
No archive, IPA or App Store upload was produced on Windows. Validate both device families on a Mac first. Then choose a real device destination and Product → Archive, validate through Organizer, and distribute to TestFlight. The app requires owner-approved icons, signing, privacy disclosures and store metadata before submission.

## Manual acceptance matrix
- Fresh launch in Arabic; switch English and restart; verify tab/side labels, RTL/LTR and back behavior.
- iPhone portrait/landscape; iPad split screen and landscape; largest Dynamic Type; VoiceOver and reduced motion.
- Favorites and recent history persist; clearing history does not clear favorites.
- Search Arabic and English section titles; zero-result state; offline native browsing.
- Load each verified web route; airplane-mode load/retry; process termination; back/forward; return to page without reload.
- Real file upload and download with a consenting test account, cancellation, multiple downloads, malicious filename.
- External links and new-window links, redirects, cookie persistence, login/logout.
- BioLab touch/drag/audio/full-screen and memory on physical iPad; Bio AI server errors and conversation retention.
- Profile with Instruments (Allocations, Leaks, Time Profiler) during repeated navigation and BioLab. Record results rather than inferring performance from code.
