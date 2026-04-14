import SwiftUI

struct LayeredBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appSurface.opacity(0.55),
                    Color.appBackground.opacity(0.92),
                    Color.appSurface.opacity(0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.appAccent.opacity(0.18),
                    Color.appAccent.opacity(0.04),
                    Color.clear
                ],
                center: UnitPoint(x: 0.15, y: 0.12),
                startRadius: 20,
                endRadius: 420
            )
            .allowsHitTesting(false)

            RadialGradient(
                colors: [
                    Color.appPrimary.opacity(0.12),
                    Color.clear
                ],
                center: UnitPoint(x: 0.85, y: 0.35),
                startRadius: 10,
                endRadius: 280
            )
            .allowsHitTesting(false)

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.18)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            Canvas { context, size in
                let spacing: CGFloat = 18
                let dotSize: CGFloat = 2
                for x in stride(from: spacing, to: size.width, by: spacing) {
                    for y in stride(from: spacing, to: size.height, by: spacing) {
                        let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                        let phase = (x + y).truncatingRemainder(dividingBy: 36)
                        let opacity = 0.08 + (phase / 360) * 0.06
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(Color.appAccent.opacity(opacity))
                        )
                    }
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

struct MeshPatternOverlay: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 44
            var path = Path()
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            context.stroke(path, with: .color(Color.appAccent.opacity(0.08)), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
