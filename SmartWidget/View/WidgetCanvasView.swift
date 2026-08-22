import SwiftUI

struct WidgetCanvasView: View {
    let layout: WidgetLayout

    private let spacing: CGFloat = 5
    private let cornerRadius: CGFloat = 36

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                if layout.isEmpty {
                    WidgetWelcomeView()
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }

                ForEach(layout.placements(in: proxy.size, spacing: spacing)) { placement in
                    tile(placement)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: layout)
    }

    private func tile(_ placement: WidgetLayout.Placement) -> some View {
        let radius = min(cornerRadius, min(placement.frame.width, placement.frame.height) / 2)
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return shape
            .fill(placement.widget.color)
            .frame(width: placement.frame.width, height: placement.frame.height)
            .appShadow()
            // Applied before .position so the tile scales about its own centre rather than the canvas.
            .transition(.scale(scale: 0.86).combined(with: .opacity))
            .position(x: placement.frame.midX, y: placement.frame.midY)
            .accessibilityElement()
            .accessibilityIdentifier("canvas.tile")
    }
}

#Preview("Empty") {
    WidgetCanvasView(layout: WidgetLayout())
        .frame(width: 320, height: 320)
        .padding()
}

#Preview("Committed layout") {
    let a = WidgetInstance(color: .skyBlue)
    let b = WidgetInstance(color: .hotPink)
    let c = WidgetInstance(color: .limeGreen)

    return WidgetCanvasView(layout: WidgetLayout(rows: [[a, b], [c]]))
        .frame(width: 320, height: 320)
        .padding()
}
