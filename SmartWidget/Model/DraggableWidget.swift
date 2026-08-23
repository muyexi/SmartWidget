import SwiftUI

struct DraggableWidget: Identifiable {
    let id: Int
    let color: Color
    var coordinate: CGPoint
    var offset: CGSize
}

extension DraggableWidget {
    static let toolbarItems: [DraggableWidget] =
    [
        .skyBlue,
        .hotPink,
        .brightYellow,
        .limeGreen,
        .vibrantOrange
    ].enumerated().map { index, color in
        DraggableWidget(id: index, color: color, coordinate: .zero, offset: .zero)
    }
}
