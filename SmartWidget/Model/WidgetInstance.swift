import SwiftUI

/// A single widget placed on the canvas.
struct WidgetInstance: Identifiable, Equatable {
    let id: UUID = UUID()
    let color: Color
}
