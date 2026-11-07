# Native experience

The app is a student discovery and navigation layer around verified club services. Home highlights study resources, services, activities and recent visits. Study, Services and Activities each use a searchable native list. More contains favorites, recent history, club links and language settings.

On compact layouts, each tab owns its NavigationStack. On regular layouts, a NavigationSplitView presents a sidebar and a detail stack. Switching a sidebar section resets its detail navigation. Compact/regular transitions do not currently restore the old navigation stack. Favorites and the last 20 unique route visits persist locally; arbitrary URLs and student form contents are not copied into native storage.

Arabic is the initial language; explicit English selection persists. The app sets both SwiftUI locale and layout direction. System fonts and semantic text styles support Dynamic Type, with multiline card text and no fixed text heights. Standard List/NavigationLink/Button controls provide accessibility semantics. VoiceOver and the largest text sizes still require device review.

Brand evidence: the official homepage source inspected on 2026-11-07 defines theme color and --ink as #6366f1, with violet, green, cyan and gold secondary accents. The native accent follows that indigo. The hero uses a darker indigo for white text contrast. System grouped backgrounds adapt to light and dark appearance. No unapproved logo artwork is included; an SF Symbol leaf provides a temporary visual mark.

Content search intentionally searches the route catalog in both languages. Full-text academic resources remain searchable within the website. No native event feed, course database, membership backend or AI endpoint is invented.

Web navigation retains the website's own content headers because no verified embedded mode was supplied. Native title/navigation chrome is separate. Hiding DOM navigation via fragile injected CSS is deferred pending an official embed contract; duplicate site headers are a known UX limitation.
