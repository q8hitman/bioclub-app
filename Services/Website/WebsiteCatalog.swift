import Foundation

enum WebsiteCatalog {
    // Verified against the public website on 2026-11-07. No inferred API routes.
    static let routes: [WebsiteRoute] = [
        .init(id: "notes", path: "notes.html", titleAR: "المراجعات", titleEN: "Study notes", subtitleAR: "المذكرات والمراجعات الدراسية", subtitleEN: "Student notes and revision resources", symbol: "books.vertical", category: .study),
        .init(id: "explain", path: "explain.html", titleAR: "شرح المواد", titleEN: "Course explanations", subtitleAR: "شروحات تساعدك على فهم المقررات", subtitleEN: "Explanations to support your studies", symbol: "play.rectangle", category: .study),
        .init(id: "majors", path: "majors.html", titleAR: "التخصصات", titleEN: "Majors", subtitleAR: "تعرّف على تخصصات العلوم البيولوجية", subtitleEN: "Explore biological sciences majors", symbol: "leaf", category: .study),
        .init(id: "advisors", path: "advisors.html", titleAR: "المرشدون الأكاديميون", titleEN: "Academic advisors", subtitleAR: "معلومات الإرشاد الأكاديمي", subtitleEN: "Find academic advising information", symbol: "person.crop.rectangle", category: .study),
        .init(id: "services", path: "services.html", titleAR: "الأدوات الأكاديمية", titleEN: "Academic tools", subtitleAR: "حاسبة المعدل ومنظم الجدول وإنجاز التخرج", subtitleEN: "GPA calculator, schedule planner and graduation progress", symbol: "calculator", category: .services),
        .init(id: "bio-ai", path: "ask.html", titleAR: "اسأل النادي", titleEN: "Ask the club", subtitleAR: "مساعد بايو والتواصل مع فريق النادي", subtitleEN: "Bio assistant and questions for the club", symbol: "bubble.left.and.bubble.right", category: .services),
        .init(id: "biolab", path: "virtual-lab/", titleAR: "المختبر الافتراضي", titleEN: "BioLab", subtitleAR: "مختبر بيولوجيا جزيئية؛ يُفضّل الآيباد بالعرض", subtitleEN: "Molecular biology lab; landscape iPad recommended", symbol: "testtube.2", category: .services),
        .init(id: "biolab-quick", path: "virtual-lab/simple.html", titleAR: "المختبر السريع", titleEN: "Quick laboratory", subtitleAR: "نسخة مختصرة من التجربة الافتراضية", subtitleEN: "A shorter virtual laboratory experience", symbol: "timer", category: .services),
        .init(id: "events", path: "events.html", titleAR: "أنشطة النادي", titleEN: "Club activities", subtitleAR: "اكتشف فعاليات النادي وأنشطته", subtitleEN: "Explore club events and activities", symbol: "calendar", category: .activities),
        .init(id: "creators", path: "creators.html", titleAR: "المبدعون", titleEN: "Student creators", subtitleAR: "مشاركات وإبداعات الطلبة", subtitleEN: "Student contributions and creativity", symbol: "paintpalette", category: .activities),
        .init(id: "about", path: "about.html", titleAR: "عن النادي", titleEN: "About the club", subtitleAR: "نادي العلوم البيولوجية بجامعة الكويت", subtitleEN: "Biological Sciences Club at Kuwait University", symbol: "info.circle", category: .more),
        .init(id: "join", path: "join.html", titleAR: "انضم للنادي", titleEN: "Join the club", subtitleAR: "تعرّف على العضوية وقدّم طلبك عبر الموقع", subtitleEN: "Learn about membership and apply on the website", symbol: "person.badge.plus", category: .more)
    ]
}
