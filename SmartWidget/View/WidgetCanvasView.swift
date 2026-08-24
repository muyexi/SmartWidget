import SwiftUI

struct WidgetCanvasView: View {
    let canvas: WidgetCanvas

    private let spacing: CGFloat = 0
    private let cornerRadius: CGFloat = 36

    var body: some View {
        ZStack {
            if canvas.isEmpty {
                WidgetWelcomeView()
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            WidgetTileLayout(canvas: canvas, spacing: spacing) {
                ForEach(canvas.widgets) { widget in
                    widgetTileView(widget)
                }
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: canvas)
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
    WidgetCanvasView(canvas: WidgetCanvas())
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

    WidgetCanvasView(canvas: WidgetCanvas(
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
