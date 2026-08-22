import SwiftUI

/// A single widget placed on the canvas.
struct WidgetInstance: Identifiable, Equatable {
    let id: UUID
    let color: Color

    init(id: UUID = UUID(), color: Color) {
        self.id = id
        self.color = color
    }
}
