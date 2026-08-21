import SwiftUI

struct Widget: Identifiable {
    let id: Int
    let color: Color
    var coordinate: CGPoint
    var offset: CGSize
}

extension Widget {
    static let toolbarItems: [Widget] =
    [
        .skyBlue,
        .hotPink,
        .brightYellow,
        .limeGreen,
        .vibrantOrange
    ].enumerated().map { index, color in
        Widget(id: index, color: color, coordinate: .zero, offset: .zero)
    }
}
