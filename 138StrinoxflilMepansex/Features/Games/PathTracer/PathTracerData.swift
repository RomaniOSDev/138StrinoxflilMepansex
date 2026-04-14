import CoreGraphics
import Foundation

enum PathTracerData {
    static func polyline(for level: Int) -> [CGPoint] {
        let clamped = min(GameConstants.levelsPerGame - 1, max(0, level))
        let segments = 32 + clamped * 2
        var points: [CGPoint] = []
        for index in 0..<segments {
            let t = CGFloat(index) / CGFloat(segments - 1)
            let x = 0.06 + 0.88 * t
            let wave = sin(t * .pi * CGFloat(2 + clamped)) * (0.05 + CGFloat(clamped) * 0.01)
            let lift = pow(t, 1.1)
            let y = 0.9 - 0.78 * lift + wave
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
}
