import CoreGraphics
import Foundation

enum PolylineGeometry {
    static func length(of points: [CGPoint]) -> CGFloat {
        guard points.count > 1 else { return 0 }
        var total: CGFloat = 0
        for index in 1..<points.count {
            total += distance(points[index - 1], points[index])
        }
        return total
    }

    static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    static func closestPoint(on points: [CGPoint], to point: CGPoint) -> (distance: CGFloat, progress: CGFloat) {
        guard points.count > 1 else {
            return (distance(point, points.first ?? .zero), 0)
        }

        var bestDistance = CGFloat.greatestFiniteMagnitude
        var bestProgress: CGFloat = 0
        let totalLength = length(of: points)
        guard totalLength > 0 else { return (0, 0) }

        var accumulated: CGFloat = 0

        for index in 1..<points.count {
            let a = points[index - 1]
            let b = points[index]
            let segmentLength = distance(a, b)
            guard segmentLength > 0 else {
                continue
            }

            let clamped = closestPointOnSegment(point: point, segmentStart: a, segmentEnd: b)
            let dist = distance(point, clamped)
            if dist < bestDistance {
                bestDistance = dist
                let localAlong = distance(a, clamped)
                bestProgress = (accumulated + localAlong) / totalLength
            }
            accumulated += segmentLength
        }

        return (bestDistance, min(1, max(0, bestProgress)))
    }

    private static func closestPointOnSegment(point: CGPoint, segmentStart a: CGPoint, segmentEnd b: CGPoint) -> CGPoint {
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let ap = CGPoint(x: point.x - a.x, y: point.y - a.y)
        let abLengthSquared = ab.x * ab.x + ab.y * ab.y
        guard abLengthSquared > 0 else { return a }
        var t = (ap.x * ab.x + ap.y * ab.y) / abLengthSquared
        t = min(1, max(0, t))
        return CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
    }

    static func point(at progress: CGFloat, on points: [CGPoint]) -> CGPoint {
        guard points.count > 1 else { return points.first ?? .zero }
        let clamped = min(1, max(0, progress))
        let totalLength = length(of: points)
        guard totalLength > 0 else { return points[0] }

        let target = clamped * totalLength
        var accumulated: CGFloat = 0

        for index in 1..<points.count {
            let a = points[index - 1]
            let b = points[index]
            let segmentLength = distance(a, b)
            if accumulated + segmentLength >= target {
                let local = segmentLength > 0 ? (target - accumulated) / segmentLength : 0
                return CGPoint(
                    x: a.x + (b.x - a.x) * local,
                    y: a.y + (b.y - a.y) * local
                )
            }
            accumulated += segmentLength
        }

        return points.last ?? points[0]
    }
}
