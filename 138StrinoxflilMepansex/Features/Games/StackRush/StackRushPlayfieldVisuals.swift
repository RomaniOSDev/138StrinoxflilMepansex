import SwiftUI

// MARK: - Playfield background (Stack Rush only)

/// Vertical “tower” backdrop: gradient sky, soft landing glow, and subtle depth lines.
struct StackRushPlayfieldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appSurface.opacity(0.45),
                    Color.appBackground.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.appAccent.opacity(0.14),
                    Color.clear,
                    Color.appPrimary.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.appAccent.opacity(0.22),
                    Color.appAccent.opacity(0.05),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.92),
                startRadius: 8,
                endRadius: 220
            )

            Canvas { context, size in
                let steps = 14
                for i in 0..<steps {
                    let t = CGFloat(i + 1) / CGFloat(steps + 1)
                    let y = size.height * t
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(
                        path,
                        with: .color(Color.appTextPrimary.opacity(0.03 + Double(i % 3) * 0.015)),
                        lineWidth: 1
                    )
                }

                let midX = size.width * 0.5
                var guide = Path()
                let dash: CGFloat = 6
                var y: CGFloat = size.height * 0.08
                while y < size.height * 0.92 {
                    guide.move(to: CGPoint(x: midX, y: y))
                    guide.addLine(to: CGPoint(x: midX, y: min(y + dash, size.height * 0.92)))
                    y += dash * 2
                }
                context.stroke(
                    guide,
                    with: .color(Color.appAccent.opacity(0.12)),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round)
                )
            }
            .allowsHitTesting(false)

            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.appSurface.opacity(0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 72)
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Slabs

enum StackRushSlabKind: Equatable {
    case foundation
    case stacked(variant: Int)
    case active
}

struct StackRushSlab: View {
    let width: CGFloat
    let height: CGFloat
    let kind: StackRushSlabKind

    private var corner: CGFloat { min(11, height * 0.45) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(gradient)

            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.appTextPrimary.opacity(kind == .active ? 0.45 : 0.22),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: kind == .foundation ? 1.5 : 1
                )

            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(Color.appAccent.opacity(strokeOpacity), lineWidth: 1)
        }
        .frame(width: max(12, width), height: height)
        .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
    }

    private var strokeOpacity: Double {
        switch kind {
        case .foundation: return 0.45
        case .active: return 0.55
        case .stacked: return 0.28
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .active:
            return Color.appAccent.opacity(0.45)
        case .foundation:
            return Color.appPrimary.opacity(0.35)
        case .stacked:
            return Color.appTextPrimary.opacity(0.18)
        }
    }

    private var shadowRadius: CGFloat {
        switch kind {
        case .active: return 14
        case .foundation: return 10
        case .stacked: return 6
        }
    }

    private var shadowY: CGFloat {
        switch kind {
        case .active: return 5
        default: return 3
        }
    }

    private var gradient: LinearGradient {
        switch kind {
        case .foundation:
            return LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.95),
                    Color.appAccent.opacity(0.75),
                    Color.appPrimary.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .active:
            return LinearGradient(
                colors: [
                    Color.appTextPrimary.opacity(0.95),
                    Color.appPrimary.opacity(0.92),
                    Color.appAccent.opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .stacked(let variant):
            let colors = Self.stackedPalettes[variant % Self.stackedPalettes.count]
            return LinearGradient(
                colors: colors,
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private static let stackedPalettes: [[Color]] = [
        [Color.appAccent.opacity(0.82), Color.appPrimary.opacity(0.72)],
        [Color.appPrimary.opacity(0.88), Color.appAccent.opacity(0.62)],
        [Color.appAccent.opacity(0.68), Color.appSurface.opacity(0.9)],
        [Color.appPrimary.opacity(0.78), Color.appAccent.opacity(0.55)],
        [Color.appAccent.opacity(0.75), Color.appPrimary.opacity(0.68)]
    ]
}
