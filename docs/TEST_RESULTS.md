# Test results

Date: 2026-11-07. Local environment: Windows, Python 3.12, Git; no Swift compiler, Xcode or iOS simulator installed.

| Check | Actual result |
| --- | --- |
| Public route requests | 12/12 returned HTTP 200; no form submission or authenticated flow tested |
| Swift grammar parser | PASS: all 15 Swift files using tree-sitter-swift 0.7.4 |
| Project membership/references | PASS: 67 unique, resolved project objects; all Swift files registered |
| OpenStep project parser | PASS using openstep-parser 2.0.3 |
| Plists and shared scheme XML | PASS |
| ATS configuration | PASS: default transport security, no arbitrary-load exception |
| Git whitespace check | PASS on integrated source |
| Native independent source review | Completed by Codex reviewer and actual Claude Code; supported findings fixed |
| Website integration source review | Completed by Codex lead; touch targets, external confirmation and frame-dialog restrictions corrected |
| Xcode build / XCTest / UI tests | Not run locally; macOS CI attempt pending |
| Real devices / VoiceOver / layout / Instruments | NOT RUN |
| Signing / archive / App Store validation | NOT RUN |

Grammar and structural checks do not type-check Swift, resolve Apple APIs, prove runtime behavior, or certify accessibility/performance. HTTP 200 is reachability evidence only. Unit and UI test source is supplied for execution on Mac; see BUILD_AND_DISTRIBUTION.md.
