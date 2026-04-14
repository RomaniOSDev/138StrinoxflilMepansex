import SwiftUI

/// Static hero strip for Home (no TimelineView — avoids scroll jank with Canvas at 30fps).
struct PlayHeroBanner: View {
    var body: some View {
        Canvas { context, size in
            let wave: CGFloat = 0

            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height * 0.65 + wave))
            path.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.55 - wave),
                control: CGPoint(x: size.width * 0.5, y: size.height * 0.2)
            )

            context.stroke(
                path,
                with: .color(Color.appAccent.opacity(0.55)),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )

            let orb = CGRect(
                x: size.width * 0.5 - 18,
                y: size.height * 0.25,
                width: 36,
                height: 36
            )
            context.fill(Path(ellipseIn: orb), with: .color(Color.appPrimary.opacity(0.85)))
        }
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.62),
                        Color.appAccent.opacity(0.12),
                        Color.appBackground.opacity(0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                LinearGradient(
                    colors: [Color.appTextPrimary.opacity(0.1), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
        }
        .drawingGroup()
    }
}
