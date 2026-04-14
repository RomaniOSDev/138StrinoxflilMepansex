import Foundation

/// Outbound URLs for settings (privacy, terms). Replace hosts when your pages are live.
enum AppExternalLink: String {
    case privacyPolicy = "https://strinoxflil138mepansex.site/privacy/104"
    case termsOfUse = "https://strinoxflil138mepansex.site/terms/104"

    var url: URL? {
        URL(string: rawValue)
    }
}
