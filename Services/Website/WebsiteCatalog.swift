import Foundation

enum WebsiteCatalog {
    // Verified against the public website on 2026-11-07. No inferred API routes.
    static let routes: [WebsiteRoute] = [
        .init(id: "notes", path: "notes.html", titleAR: "المراجعات", titleEN: "Study notes", subtitleAR: "المذكرات والمراجعات الدراسية", subtitleEN: "Student notes and revision resources", symbol: "books.vertical", category: .study),
        .init(id: "explain", path: "explain.html", titleAR: "شرح المواد", titleEN: "Course explanations", subtitleAR: "شروحات تساعدك على فهم المقررات", subtitleEN: "Explanations to support your studies", symbol: "play.rectangle", category: .study),
        .init(id: "majors", path: "majors.html", titleAR: "التخصصات", titleEN: "Majors", subtitleAR: "تعرّف على تخصصات العلوم البيولوجية", subtitleEN: "Explore biological sciences majors", symbol: "leaf", category: .study),
        .init(id: "advisors", path: "advisors.html", titleAR: "المرشدون الأكاديميون", titleEN: "Academic advisors", subtitleAR: "معلومات الإرشاد الأكاديمي", subtitleEN: "Find academic advising information", symbol: "person.crop.rectangle", category: .study),
        // Direct links into services.html tabs (site reads ?tab= via getDeepParam).
        // Listed first so Home's services shortcuts open the most-used tools.
        .init(id: "gpa", path: "services.html?tab=gpa", titleAR: "حاسبة المعدل", titleEN: "GPA calculator", subtitleAR: "احسب معدلك الفصلي والتراكمي", subtitleEN: "Work out your term and cumulative GPA", symbol: "function", category: .services),
        .init(id: "planner", path: "services.html?tab=planner", titleAR: "منظم الجدول", titleEN: "Schedule planner", subtitleAR: "رتّب جدولك واكتشف التعارضات", subtitleEN: "Build your timetable and spot clashes", symbol: "calendar.badge.plus", category: .services),
        .init(id: "graduation", path: "services.html?tab=grad", titleAR: "إنجاز التخرج", titleEN: "Graduation progress", subtitleAR: "تابع المقررات المنجزة والمتبقية", subtitleEN: "Track completed and remaining courses", symbol: "graduationcap", category: .services),
        .init(id: "services", path: "services.html", titleAR: "الأدوات الأكاديمية", titleEN: "Academic tools", subtitleAR: "الأخبار والجداول المقترحة ودليل الطالب والملفات وتقييم المواد", subtitleEN: "News, suggested schedules, student guide, files and course ratings", symbol: "calculator", category: .services),
        .init(id: "bio-ai", path: "ask.html", titleAR: "اسأل النادي", titleEN: "Ask the club", subtitleAR: "مساعد بايو والتواصل مع فريق النادي", subtitleEN: "Bio assistant and questions for the club", symbol: "bubble.left.and.bubble.right", category: .services),
        .init(id: "biolab", path: "virtual-lab/", titleAR: "المختبر الافتراضي", titleEN: "BioLab", subtitleAR: "مختبر بيولوجيا جزيئية؛ يُفضّل الآيباد بالعرض", subtitleEN: "Molecular biology lab; landscape iPad recommended", symbol: "testtube.2", category: .services),
        .init(id: "biolab-quick", path: "virtual-lab/simple.html", titleAR: "المختبر السريع", titleEN: "Quick laboratory", subtitleAR: "نسخة مختصرة من التجربة الافتراضية", subtitleEN: "A shorter virtual laboratory experience", symbol: "timer", category: .services),
        .init(id: "events", path: "events.html", titleAR: "أنشطة النادي", titleEN: "Club activities", subtitleAR: "اكتشف فعاليات النادي وأنشطته", subtitleEN: "Explore club events and activities", symbol: "calendar", category: .activities),
        .init(id: "creators", path: "creators.html", titleAR: "المبدعون", titleEN: "Student creators", subtitleAR: "مشاركات وإبداعات الطلبة", subtitleEN: "Student contributions and creativity", symbol: "paintpalette", category: .activities),
        .init(id: "about", path: "about.html", titleAR: "عن النادي", titleEN: "About the club", subtitleAR: "نادي العلوم البيولوجية بجامعة الكويت", subtitleEN: "Biological Sciences Club at Kuwait University", symbol: "info.circle", category: .more),
        .init(id: "join", path: "join.html", titleAR: "انضم للنادي", titleEN: "Join the club", subtitleAR: "تعرّف على العضوية وقدّم طلبك عبر الموقع", subtitleEN: "Learn about membership and apply on the website", symbol: "person.badge.plus", category: .more),
        .init(id: "privacy", path: "privacy.html", titleAR: "الخصوصية والبيانات", titleEN: "Privacy and data", subtitleAR: "كيف يتعامل موقع النادي مع بياناتك", subtitleEN: "How the club website handles your data", symbol: "hand.raised", category: .more)
    ]
}
