import SwiftUI

extension View {
    /// App-standard shadow
    func appShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.5), radius: 10, x: 2, y: 2)
    }
}
