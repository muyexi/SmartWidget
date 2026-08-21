import SwiftUI

extension View {
    /// App-standard shadow
    func appShadow(_ isEnabled: Bool = true) -> some View {
        self.shadow(
            color: Color.black.opacity(isEnabled ? 0.5 : 0),
            radius: isEnabled ? 10 : 0,
            x: isEnabled ? 2 : 0,
            y: isEnabled ? 2 : 0
        )
    }
}
