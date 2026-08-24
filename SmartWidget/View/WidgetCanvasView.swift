import SwiftUI

struct WidgetCanvasView: View {
    let layout: WidgetCanvasLayout

    private let spacing: CGFloat = 0
    private let cornerRadius: CGFloat = 36

    var body: some View {
        ZStack {
            if layout.isEmpty {
                WidgetWelcomeView()
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            WidgetTileLayout(layout: layout, spacing: spacing) {
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
            .transition(.scale(scale: 0.2).combined(with: .opacity))
            .accessibilityElement()
            .accessibilityIdentifier("canvas.tile")
    }
}

#Preview("Empty") {
    WidgetCanvasView(layout: WidgetCanvasLayout())
        .frame(width: 320, height: 320)
        .padding()
}

#Preview("Nested layout") {
    let a = WidgetInstance(color: .skyBlue)
    let b = WidgetInstance(color: .hotPink)
    let c = WidgetInstance(color: .vibrantOrange)
    let d = WidgetInstance(color: .skyBlue)
    let e = WidgetInstance(color: .limeGreen)
    let h = WidgetInstance(color: .brightYellow)

    WidgetCanvasView(layout: WidgetCanvasLayout(
        .row(
            .widget(a),
            .column(
                .widget(b),
                .row(.widget(c), .widget(d), .widget(e)),
                .widget(h))
        )
    ))
    .frame(width: 320, height: 320)
    .padding()
}
