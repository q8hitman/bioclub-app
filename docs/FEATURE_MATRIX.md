# Delivery coverage

| Requirement | Implementation / remaining verification |
| --- | --- |
| Swift 6, SwiftUI, iPhone/iPad | App and generated Xcode project; iOS 17 minimum |
| Native home and five destinations | Home, Study, Services, Activities, More; compact tabs and regular sidebar |
| Search | Native bilingual route search; resource-content search remains website-owned |
| Favorites and recently viewed | On-device IDs, deduplicated 20-entry history, clear-history confirmation |
| Arabic/English, RTL/LTR | Native paired strings, locale/layout direction, localized permission descriptions; site language independent |
| Light/dark, Dynamic Type | System grouped UI and scalable text; actual large-type/VoiceOver certification still needed |
| Branding | Official indigo palette and original official logo; square store icon outstanding |
| Loading/offline/errors | Native catalog remains available; WebKit loading, retry, failed-destination recovery and browser fallback |
| Verified pages | 12 HTTP-checked routes; full inventory in WEBSITE_AUDIT.md |
| GPA/planner/graduation | Existing services page preserved; no invented deep links or backend |
| Membership/events/Bio AI | Existing web pages; authenticated/form/AI end-to-end checks outstanding |
| BioLab | Full and express routes, landscape hint; WebGL/touch/audio/device testing outstanding |
| Session preservation | Persistent WebKit store; StateObject retains view through redraws; no custom token storage |
| External navigation | HTTPS confirmation; exact internal host; unsafe schemes denied; narrow verified video-frame allowlist |
| Downloads/documents | Club-origin WKDownload, safe temporary filenames, native share/Files export; inline PDFs |
| Uploads | WebKit system picker, localized camera/video usage strings; explicit WebRTC capture denial |
| Unsupported exports | Blob-generated schedule exports require browser fallback; no unsafe JS bridge |
| Unit/UI checks | Source provided and macOS CI configured; exact executed results in TEST_RESULTS.md |
| Collaboration | Separate worktrees/branches; explicit transfer after Claude implementation stalls; actual Claude native review and Codex cross-review |
| Distribution | Build guide and checklist provided; no signing identity, IPA, TestFlight or store submission |

App code is kept on the reviewed development branch and draft PR. Main is not treated as release-ready until required Apple checks and acceptance criteria pass.
