import SwiftUI

struct WidgetCanvasView: View {
    let layout: WidgetLayout

    private let spacing: CGFloat = 5
    private let cornerRadius: CGFloat = 36

    var body: some View {
        ZStack {
            if layout.isEmpty {
                WidgetWelcomeView()
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            WidgetGridLayout(layout: layout, spacing: spacing) {
                ForEach(layout.widgets) { widget in
                    widgetTileView(widget)
                }
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: layout)
    }

    private func widgetTileView(_ widget: WidgetInstance) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(widget.color)
            .appShadow()
            .transition(.scale(scale: 0.2).combined(with: .opacity))
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

    WidgetCanvasView(layout: WidgetLayout(rows: [[a, b], [c]]))
        .frame(width: 320, height: 320)
        .padding()
}
