import SwiftUI

struct WidgetGridLayout: Layout {
    let layout: WidgetCanvasLayout
    var spacing: CGFloat = 0

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let placements = layout.placements(in: bounds.size, spacing: spacing)

        for (subview, placement) in zip(subviews, placements) {
            let frame = placement.frame.offsetBy(dx: bounds.minX, dy: bounds.minY)
            subview.place(
                at: CGPoint(x: frame.midX, y: frame.midY),
                anchor: .center,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
}
