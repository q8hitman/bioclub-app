# Integration status

2026-11-07: SwiftUI native app and verified WebKit integration implemented on `codex/ios-app`. `main` contains the initial contract/documentation baseline only. Website work lives on `claude/web-integration`; reviewed commits were cherry-picked into the app branch. No production website was modified.

## Delivered source
- Native adaptive home, study, services, activities and more screens.
- Arabic-first UI and English selection, local favorites/recents, catalog search, light/dark and Dynamic Type styles.
- Verified 12-route catalog, exact-origin URL policy, persistent cookies, loading/retry, back/forward, external confirmation, native sharing/download handling and browser fallback.
- Xcode project, shared scheme, unit/UI tests, portable checks and a macOS CI workflow.

## Collaboration record
Actual Claude Code audited public pages but two implementation attempts stalled before writing files. Those task processes were stopped and ownership explicitly transferred to the Codex integration worker; the memory worker was not restarted. Claude later completed a tool-free native-source review. Codex reviewed the web implementation; native review was also independently checked by a Codex reviewer. See AGENT_TASKS.md for accepted findings and rejected unsupported claims.

## Release blockers and known limits
- Apple compilation and simulator test outcome: see TEST_RESULTS.md for the latest evidence. Local Windows checks cannot establish buildability.
- Physical-device layout/accessibility/performance, login, Bio AI, BioLab, uploads and downloads need validation.
- Locally generated blob exports use browser fallback; the browser has a separate cookie session.
- No verified API contract exists for feeds or AI, so these remain web experiences.
- Website language and content headers remain website-owned; duplicate native/site headers may appear.
- Navigation stack paths do not persist across app restarts or compact/regular layout changes.
- Temporary file cleanup is best-effort; unknown-length downloads have no streaming byte cap.
- Signing, approved icons, privacy/store metadata and student acceptance testing remain outstanding.

This is an implementation candidate, not a signed or production-certified release. Do not merge app code to main until Apple validation and required review pass.
