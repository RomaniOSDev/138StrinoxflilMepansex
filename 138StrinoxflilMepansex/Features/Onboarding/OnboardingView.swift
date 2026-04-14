import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var storage: GameStorage
    @StateObject private var viewModel = OnboardingViewModel()

    private var progress: CGFloat {
        guard !viewModel.pages.isEmpty else { return 0 }
        return CGFloat(viewModel.pageIndex + 1) / CGFloat(viewModel.pages.count)
    }

    var body: some View {
        ZStack {
            LayeredBackgroundView()

            VStack(spacing: 0) {
                onboardingHeader

                TabView(selection: $viewModel.pageIndex) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(
                            page: page,
                            pageNumber: index + 1,
                            totalPages: viewModel.pages.count
                        )
                        .tag(index)
                        .padding(.horizontal, 16)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.32), value: viewModel.pageIndex)
                .frame(minHeight: 460)

                onboardingPageControl

                onboardingCTA
            }
        }
    }

    private var onboardingHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick tour")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary.opacity(0.88))

                    Text("Three beats to get you moving.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.35),
                                    Color.appAccent.opacity(0.28)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.appAccent.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appSurface.opacity(0.42))
                        .overlay(
                            Capsule()
                                .stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appAccent.opacity(0.95),
                                    Color.appPrimary.opacity(0.88)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, geo.size.width * progress))
                        .shadow(color: Color.appAccent.opacity(0.35), radius: 6, x: 0, y: 0)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    private var onboardingPageControl: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.pages.count, id: \.self) { index in
                Group {
                    if index == viewModel.pageIndex {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appPrimary.opacity(0.92)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    } else {
                        Capsule()
                            .fill(Color.appTextPrimary.opacity(0.22))
                    }
                }
                .frame(width: index == viewModel.pageIndex ? 28 : 9, height: 9)
                .shadow(
                    color: index == viewModel.pageIndex ? Color.appAccent.opacity(0.35) : .clear,
                    radius: 6,
                    x: 0,
                    y: 2
                )
                .animation(.spring(response: 0.38, dampingFraction: 0.78), value: viewModel.pageIndex)
            }
        }
        .padding(.vertical, 14)
    }

    private var onboardingCTA: some View {
        VStack(spacing: 0) {
            Button {
                if viewModel.isLastPage {
                    storage.markOnboardingSeen()
                } else {
                    viewModel.advance()
                }
            } label: {
                ResultPrimaryButtonCell(title: viewModel.isLastPage ? "Get Started" : "Next")
            }
            .buttonStyle(.pressableScale)
        }
        .padding(16)
        .appCellSurface(fillOpacity: 0.72, strokeOpacity: 0.24, elevation: .medium)
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
    }
}

// MARK: - Page

private struct OnboardingPageView: View {
    let page: OnboardingPageModel
    let pageNumber: Int
    let totalPages: Int

    @State private var artScale: CGFloat = 0.9
    @State private var artOpacity: Double = 0

    var body: some View {
        ScrollView {
            OnboardingPageCell(
                illustration: OnboardingIllustration(kind: page.illustration)
                    .id(page.title),
                title: page.title,
                detail: page.detail,
                pageIndex: pageNumber,
                totalPages: totalPages,
                artScale: artScale,
                artOpacity: artOpacity
            )
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            artScale = 0.92
            artOpacity = 0
            withAnimation(.spring(response: 0.48, dampingFraction: 0.74)) {
                artScale = 1
                artOpacity = 1
            }
        }
    }
}

// MARK: - Illustrations

private struct OnboardingIllustration: View {
    let kind: OnboardingPageModel.IllustrationKind

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.68),
                            Color.appAccent.opacity(0.26),
                            Color.appBackground.opacity(0.48)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.appAccent.opacity(0.5),
                                    Color.appPrimary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.26), radius: 14, x: 0, y: 8)

            MeshPatternOverlay()
                .opacity(0.14)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            switch kind {
            case .rhythm:
                RhythmIllustration()
            case .stars:
                StarsIllustration()
            case .stages:
                StagesIllustration()
            }
        }
        .padding(.horizontal, 4)
    }
}

private struct RhythmIllustration: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 30, y: 150))
                path.addQuadCurve(to: CGPoint(x: 260, y: 60), control: CGPoint(x: 150, y: 210))
            }
            .stroke(
                LinearGradient(
                    colors: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 6, lineCap: .round)
            )
            .shadow(color: Color.appAccent.opacity(0.45), radius: 8, x: 0, y: 2)

            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appPrimary.opacity(0.95 - Double(index) * 0.12),
                                Color.appAccent.opacity(0.55)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 12
                        )
                    )
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .offset(x: CGFloat(index) * 36 - 54, y: CGFloat(index) * -18 + 18)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct StarsIllustration: View {
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                OnboardingStarShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.45 + Double(index) * 0.18),
                                Color.appPrimary.opacity(0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44 + CGFloat(index) * 8, height: 44 + CGFloat(index) * 8)
                    .shadow(color: Color.appAccent.opacity(0.25), radius: 6, x: 0, y: 3)
                    .offset(x: CGFloat(index - 1) * 46, y: CGFloat(index % 2) * 18)
            }

            OnboardingStarShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appTextPrimary.opacity(0.95),
                            Color.appAccent,
                            Color.appPrimary.opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 76, height: 76)
                .shadow(color: Color.appAccent.opacity(0.5), radius: 12, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OnboardingStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.45
        var path = Path()
        let points = 5
        for index in 0..<(points * 2) {
            let angle = CGFloat(index) * .pi / CGFloat(points) - .pi / 2
            let radius = index.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(
                x: center.x + CGFloat(cos(Double(angle))) * radius,
                y: center.y + CGFloat(sin(Double(angle))) * radius
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

private struct StagesIllustration: View {
    var body: some View {
        VStack(spacing: 12) {
            stageBar(width: 220, leading: Color.appAccent.opacity(0.95), trailing: Color.appAccent.opacity(0.55))
            stageBar(width: 190, leading: Color.appPrimary.opacity(0.95), trailing: Color.appPrimary.opacity(0.65))
            stageBar(width: 150, leading: Color.appAccent.opacity(0.8), trailing: Color.appAccent.opacity(0.45))

            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 54, height: 54)
                    .shadow(color: Color.appAccent.opacity(0.2), radius: 4, x: 0, y: 2)

                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface.opacity(0.95), Color.appAccent.opacity(0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.appPrimary, lineWidth: 3)
                }
                .frame(width: 54, height: 54)
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.appTextSecondary.opacity(0.45), lineWidth: 3)
                    .frame(width: 54, height: 54)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stageBar(width: CGFloat, leading: Color, trailing: Color) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [leading, trailing],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 5, x: 0, y: 3)
    }
}
