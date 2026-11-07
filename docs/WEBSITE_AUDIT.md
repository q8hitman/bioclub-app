# Website audit and integration evidence

Audit date: 2026-11-07. Public source: https://biosci-ku.com/. Read-only requests only; no forms submitted, no production modifications. The supplied GitHub repository was empty and did not contain the website source. Public HTML was available for inspection.

## Verified route inventory

Every path below was linked from the public homepage and returned HTTP 200 during this audit. A successful HTTP response proves reachability, not end-to-end functionality.

| Path | Native category | Observed purpose |
| --- | --- | --- |
| notes.html | Study | Academic notes and Google Drive link submission |
| explain.html | Study | Course explanations and embedded videos |
| majors.html | Study | Biological sciences majors |
| advisors.html | Study | Academic advisors |
| services.html | Services | GPA calculator, schedule planner, news, proposed schedules, student guide, university files, graduation progress, course ratings |
| ask.html | Services | Bio assistant and direct questions for club staff |
| virtual-lab/ | Services | Full molecular biology virtual laboratory |
| virtual-lab/simple.html | Services | Express laboratory |
| events.html | Activities | Club activities |
| creators.html | Activities | Student contributions |
| about.html | More | Club information |
| join.html | More | Membership information/form |
| privacy.html | More | Site privacy and data statement (linked from page footers) |
| services.html?tab=gpa | Services | GPA calculator tab (direct link) |
| services.html?tab=planner | Services | Schedule planner tab (direct link) |
| services.html?tab=grad | Services | Graduation progress tab (direct link) |

Direct evidence URLs use the prefix `https://biosci-ku.com/` followed by the exact path. Major detail links observed include `major.html?major=molecular`, `micro`, `plant`, `animal`, and `biochem`; these remain website navigation rather than separate native catalog entries.

## Feature dependencies and authentication

- The services page contains the GPA, planning and graduation tools in one document. **Deep links are verified in the page source** (Claude follow-up): `getDeepParam("tab")` selects one of `SERVICE_TABS = [gpa, planner, news, sched, guide, files, grad, ratings]`, and item keys `news`, `schedule`, `guide`, `file`, `rating` focus a single item. The catalog now links GPA, planner and graduation progress directly. No APIs were assumed. Student-entered web state stays under WebKit/site control (see below).
- Notes submission asks for a Google Drive link. Drive downloads and other third-party documents open in the system browser after confirmation; native WKDownload is limited to the club origin.
- `explain.html` defines `ytEmbed` with `https://www.youtube-nocookie.com/embed/{id}`. This exact host and `/embed/` path are permitted for HTTPS subframes. Other third-party frame navigations are blocked pending evidence. Top-level external navigation still requires confirmation. Video playback, cookies and fullscreen require device validation.
- Homepage external links include Kuwait University Moodle, the academic portal, Instagram and X. These are browser destinations; no credentials are intercepted or copied into app storage.
- Public pages loaded without login in HTTP checks. `account.js` (loaded on most pages) signs every visitor in with **Firebase anonymous auth** automatically; there is no login UI (Google sign-in was removed from the site). Membership submission, account deletion, consent flows and cookie behavior were not exercised.
- No stable, documented application API or authenticated API permission was verified. `Services/API` deliberately contains no speculative adapter. Public web JavaScript is not treated as an authorization to call hidden endpoints.
- Bio AI remains its existing web experience. No AI key, prompt injection, bridge, conversation scraping or alternative endpoint is introduced. The page describes informational assistance, with scheduling/course selection referred to advisors.

## WebKit policy and functionality

Only HTTPS `biosci-ku.com` (default port/443, no URL credentials) is internal. HTTPS external pages require a native confirmation before opening the system browser. Custom, data, blob, file, HTTP, credential-bearing and unusual-port URLs are blocked. `target=_blank` is handled without creating an unmanaged WebView.

`WKWebsiteDataStore.default()` preserves ordinary cookies and website storage. WebView is owned by a StateObject and updateUIView does not reload it. Native language updates do not inject or change website language; users may use the website's own language control. No JavaScript/native messaging bridge is installed. JavaScript alert, confirm and prompt receive native dialogs. WebRTC media-capture requests are explicitly denied. Standard WebKit upload inputs use the system picker; real camera/document selection needs device validation and usage descriptions supplied by the app target.

`WKDownload` retains WebKit's authenticated request context. Only club-origin downloads and redirects are accepted. Filenames are normalized and placed under random temporary directories. Successful files open the native share sheet; completed share/failure paths remove their temporary directory. Known response lengths over 100 MB are rejected; unknown streaming lengths cannot be capped by this implementation. Simultaneous completed downloads beyond one share sheet are rejected visibly. Navigating away during download or process termination may leave temporary files for OS cleanup; background downloads/resume are not implemented. PDFs WebKit can display remain inline unless sent as attachments.

## Compatibility limits and required device checks

- BioLab explicitly recommends landscape iPad and uses a graphics/touch laboratory. No actual WebKit/WebGL, audio, drag/pinch, memory, service-worker or offline-capability test was possible on Windows. Browser fallback remains available.
- Service exports are generated as `blob:` URLs (`URL.createObjectURL` + `a.download` in services.html). `classify` still treats every `blob:` as `.blocked`; a narrow exception (`WebsiteURLPolicy.isSiteBlob`) lets **only blobs whose origin is `https://biosci-ku.com`** become a `WKDownload` when WebKit marks the action as a download. They are never loaded as pages. Device check still required.
- Browser fallback uses the system browser's separate session; it may require signing in again.
- No duplicate-header DOM rewriting is performed. The website may show its own menu beneath the native title.
- Errors include retry and browser fallback; native lists/favorites remain usable offline. Web pages are not promised offline caching.
- Run login/logout, file upload/download, video, lab, Bio AI, redirects, native dialogs and accessibility checks on actual iPhone/iPad before release.

## Validation performed

All 12 route HTTP checks passed. Swift source grammar parsing and diff checks were run locally; XCTest and Apple SDK compilation are not available on this Windows host. Routing XCTest cases cover spoofed hosts, unsafe schemes/credentials/ports, embedded-video origin/path and traversal-resistant filenames. These XCTest cases must still run on the Mac build.

## Claude Code follow-up audit (2026-11-07)

Method: downloaded the public HTML/JS (`account.js`, `theme.js`, `notify.js`, `splash.js`, `sw.js`, `virtual-lab/js/main.js`) and read it. No backend requests were sent; Firestore and the AI proxy were not called.

**Student data lives on the device, inside WebKit storage.** `localStorage` keys `bscku_gpa_v2`, `bscku_planner_v1`, `bscku_major`, `bscku_grad_*`, `bscku_done_*` hold GPA, planner and graduation progress; the anonymous Firebase uid sits in IndexedDB and `account.js` syncs those sections to Firestore under it. Membership and GPA records are tied to that uid. Consequences: `WKWebsiteDataStore.default()` is mandatory (already the case); the app must never offer "clear website data" without warning that it erases the student's tools; the browser fallback is a different store and will not show the same data.

**Backend:** Firebase project `bsc-ku` (Web SDK 10.12.2: app, auth, firestore). Collections referenced per page: services (courseRatings, gpaData, majorSheets, news, schedules, studentGuide, supportSheets, universityFiles), join (memberships, membershipConfig, membershipGpaProof, membershipPhotos), ask (aiChats, humanQuestions), notes (notes, noteSubmissions), explain (courseVideos, videoComments), events, creatorEvents, announcements, advisors/faculty/scheduleCommittee, teamMembers, siteStats/dailyVisits. Security rules could not be reviewed; no native Firestore adapter should be written without club approval.

**Bio AI (`ask.html`):** the page POSTs Gemini-format requests to `https://gemini-proxy.ahmed921x.workers.dev/?model=gemini-1.5-flash` (a personal Cloudflare Worker, not a club domain) and falls back to canned local answers on failure. Google has retired the Gemini 1.5 family, so the assistant may already be answering only from the fallback — **unverified, club should check**. Every question and answer is written to Firestore `aiChats`. App Privacy details must therefore declare user content sent to a third party and stored by the club.

**Contact links:** about/advisors render `mailto:` addresses (e.g. `biosciclub@gmail.com`). Explicit policy now implemented (`WebsiteURLPolicy.contactTarget`): `mailto:`/`tel:` are acted on only from a link tap or user-gesture popup, only with a single well-formed target (no header injection such as encoded newlines), and only after the same native confirmation used for external sites. `classify` still returns `.blocked` for them.

**JS dialogs:** services.html uses `confirm()` (8×), `prompt()` and `alert()` for clearing/importing planner data; the existing native dialog handling covers them. Planner sharing uses `#s=BSC1-…` codes in the URL fragment.

**Other observations:** web `Notification` is guarded by `"Notification" in window` (absent in WKWebView, degrades silently); service-worker registration is guarded and `.catch`ed; the splash overlay (`splash.js`) shows once per session; site language/theme are `localStorage.bscku_lang` (`ar`/`en`) and `bscku_theme` (`dark` default). BioLab pages are English-only (`lang="en"`), use vendored three.js via an import map and WebGL. `sw.js` precaches an unlinked `/team.html`. No robots.txt or sitemap.xml.

**Contract notes for Codex (proposals, not implemented):**
1. `www.biosci-ku.com` is treated as external; if the site ever links it, it will prompt as an external site.
2. Hiding the site's own top bar (`#navbar`, `#mobileMenu`, `#installBtn`) would remove the duplicate header but needs DOM injection, which the contract currently forbids. Leaving as is.

## Authorship and handoff

Actual Claude Code completed an initial public-page audit but its implementation sessions stalled with no files written. The lead explicitly transferred this worktree's web ownership to a Codex integration worker. This implementation is that fallback's work, not a claim of Claude-authored code. The lead owns integration and final cross-review.

Follow-up commits on this branch after the fallback implementation (contact-link policy, site-blob downloads, services deep links, privacy route, this audit section) are authored by Claude Code.
