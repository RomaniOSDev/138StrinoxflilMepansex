import Combine
import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var pageIndex: Int = 0

    let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            title: "Feel the Rhythm",
            detail: "Every drop, trace, and stack rewards patience and precision.",
            illustration: .rhythm
        ),
        OnboardingPageModel(
            title: "Earn Bright Stars",
            detail: "Stars reflect your accuracy—clean runs shine the brightest.",
            illustration: .stars
        ),
        OnboardingPageModel(
            title: "Climb the Stages",
            detail: "Unlock tougher layouts as your skill climbs higher.",
            illustration: .stages
        )
    ]

    var isLastPage: Bool {
        pageIndex >= pages.count - 1
    }

    func advance() {
        guard !isLastPage else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            pageIndex += 1
        }
    }
}

struct OnboardingPageModel: Identifiable {
    enum IllustrationKind {
        case rhythm
        case stars
        case stages
    }

    let id = UUID()
    let title: String
    let detail: String
    let illustration: IllustrationKind
}
