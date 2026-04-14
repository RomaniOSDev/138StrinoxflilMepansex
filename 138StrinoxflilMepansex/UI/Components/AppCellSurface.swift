import SwiftUI

// MARK: - Elevation (shadows)

enum AppElevation {
    case none
    case soft
    case medium
    case deep
    case lifted

    var shadowColor: Color {
        switch self {
        case .none: return .clear
        case .soft: return Color.black.opacity(0.14)
        case .medium: return Color.black.opacity(0.22)
        case .deep: return Color.black.opacity(0.32)
        case .lifted: return Color.black.opacity(0.26)
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .none: return 0
        case .soft: return 6
        case .medium: return 10
        case .deep: return 14
        case .lifted: return 12
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .none: return 0
        case .soft: return 3
        case .medium: return 5
        case .deep: return 8
        case .lifted: return 7
        }
    }
}

/// Shared “cell” chrome: gradient surface, accent stroke, top light, shadow.
struct AppCellSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var fillOpacity: Double = 0.92
    var strokeOpacity: Double = 0.18
    var strokeWidth: CGFloat = 1
    var elevation: AppElevation = .medium
    /// Extra darkening for “recessed” tiles (muted / playfield).
    var bottomShade: Double = 1.0

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(min(1, fillOpacity * 1.12)),
                                    Color.appSurface.opacity(fillOpacity * 0.72 * bottomShade)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appTextPrimary.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: UnitPoint(x: 0.5, y: 0.55)
                            )
                        )

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.appTextPrimary.opacity(0.06),
                                    Color.clear
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            ),
                            lineWidth: 1
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.appAccent.opacity(strokeOpacity), lineWidth: strokeWidth)
            )
            .shadow(color: elevation.shadowColor, radius: elevation.shadowRadius, x: 0, y: elevation.shadowY)
    }
}

extension View {
    func appCellSurface(
        cornerRadius: CGFloat = 16,
        fillOpacity: Double = 0.92,
        strokeOpacity: Double = 0.18,
        strokeWidth: CGFloat = 1,
        elevation: AppElevation = .medium,
        bottomShade: Double = 1.0
    ) -> some View {
        modifier(
            AppCellSurfaceModifier(
                cornerRadius: cornerRadius,
                fillOpacity: fillOpacity,
                strokeOpacity: strokeOpacity,
                strokeWidth: strokeWidth,
                elevation: elevation,
                bottomShade: bottomShade
            )
        )
    }

    /// Dense grid tiles (level picker, small controls).
    func appCellInset() -> some View {
        appCellSurface(cornerRadius: 14, fillOpacity: 0.95, strokeOpacity: 0.22, elevation: .soft)
    }

    /// Muted / locked state.
    func appCellMuted(fillOpacity: Double = 0.55, strokeOpacity: Double = 0.2) -> some View {
        appCellSurface(
            cornerRadius: 14,
            fillOpacity: fillOpacity,
            strokeOpacity: strokeOpacity,
            elevation: .soft,
            bottomShade: 0.88
        )
    }

    /// Playfield / canvas container — reads slightly “sunk” with deeper shadow.
    func appCellPlayfield() -> some View {
        appCellSurface(
            cornerRadius: 16,
            fillOpacity: 0.55,
            strokeOpacity: 0.3,
            elevation: .deep,
            bottomShade: 0.82
        )
    }

    /// Outer wrap for achievement tiles (soft outer pad).
    func appCellOuterPad() -> some View {
        appCellSurface(cornerRadius: 16, fillOpacity: 0.38, strokeOpacity: 0.16, elevation: .soft, bottomShade: 0.92)
    }
}

struct AppSectionTitle: View {
    let text: String
    var topPadding: CGFloat = 0
    /// Use on light cell surfaces (e.g. difficulty card). Scroll sections on the dark background use the default.
    var onLightSurface: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(onLightSurface ? Color.appTextSecondary : Color.appTextPrimary.opacity(0.78))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, topPadding)
    }
}
