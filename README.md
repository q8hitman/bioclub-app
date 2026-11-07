# BSC KU — نادي العلوم البيولوجية

Arabic-first iPhone and iPad app for the Biological Sciences Club at Kuwait University. Swift 6, SwiftUI, iOS 17+, with verified website features hosted in WebKit.

## Open and run

Open **BSCKU.xcodeproj** on a Mac with Xcode 26.6 (the CI-tested toolchain). Select **BSCKU**, select an available iPhone or iPad simulator, then Run. No third-party packages are needed. Set your development team for physical devices.

## Implemented native experience

- Home dashboard, iPhone tabs and iPad sidebar.
- Study, services and activities discovery with Arabic/English catalog search.
- Locally persisted favorites, recent history and language preference.
- Adaptive system typography, RTL/LTR, light/dark appearance and native navigation.
- Website destination integration with native navigation and favorite controls.

## Documentation

- [Architecture](docs/ARCHITECTURE.md) and [native design](docs/NATIVE_DESIGN.md)
- [Integration contract](docs/API_CONTRACT.md) and [ownership](docs/AGENT_TASKS.md)
- [Website audit](docs/WEBSITE_AUDIT.md)
- [Integration status](docs/INTEGRATION_STATUS.md) and [test results](docs/TEST_RESULTS.md)
- [Build/distribution](docs/BUILD_AND_DISTRIBUTION.md) and [App Store readiness](docs/APP_STORE_READINESS.md)

## Validation

```sh
python3 scripts/generate_project.py
python3 scripts/validate_project.py
```

Optional grammar-only check: install `tree-sitter` and `tree-sitter-swift`, then run `python3 scripts/parse_swift.py`. It does not replace compilation. Run XCTest through Xcode; the macOS GitHub Actions workflow is supplied for remote validation.

This source was authored on Windows. Consult the test report for actual executed checks and outstanding Apple-platform validation. It is not a signed release or a claim of App Store readiness.
