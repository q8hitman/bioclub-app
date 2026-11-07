# Language policy
Arabic (Modern Standard Arabic) is the initial UI language. More → Language switches to English. The preference is stored locally. SwiftUI receives matching locale and layoutDirection environments. System controls follow the supplied locale where supported. Website language remains website-owned; no undocumented query parameters or injected DOM changes are used.

Native labels are explicitly paired at their call sites via AppStore.text; catalog titles and descriptions have required AR/EN fields. Before release, review system dialogs on devices using both OS languages and VoiceOver. Website text is not translated by the app.
