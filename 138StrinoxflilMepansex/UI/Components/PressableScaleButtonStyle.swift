import SwiftUI

struct PressableScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableScaleButtonStyle {
    static var pressableScale: PressableScaleButtonStyle { PressableScaleButtonStyle() }
}
