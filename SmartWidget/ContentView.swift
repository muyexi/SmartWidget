import SwiftUI

struct ContentView: View {
    @State private var layout = WidgetLayout()

    /// The canvas rectangle in global coordinates, used to convert the drag
    /// gesture's global location into the canvas' own space.
    @State private var canvasFrame: CGRect = .zero

    /// The drop currently being previewed, if any.
    @State private var pendingDrop: PendingDrop?

    var body: some View {
        VStack {
            Spacer()

            dropArea

            Spacer()

            WidgetToolbar(
                isPreviewing: pendingDrop != nil,
                onDrag: previewDrop,
                onDrop: commitDrop
            )
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var dropArea: some View {
        GeometryReader { proxy in
            WidgetCanvasView(layout: pendingDrop?.layout ?? layout)
                .onAppear {
                    canvasFrame = proxy.frame(in: .global)
                }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
    }

    // MARK: - Gesture handling

    /// Shows where the widget would land, without changing the committed layout.
    private func previewDrop(_ widget: Widget) {
        guard canvasFrame.contains(widget.coordinate) else {
            pendingDrop = nil
            return
        }

        let instance = pendingDrop?.widget ?? WidgetInstance(color: widget.color)
        let layout = layout.inserting(instance, at: canvasPoint(for: widget), in: canvasFrame.size)

        pendingDrop = PendingDrop(widget: instance, layout: layout)
    }

    /// Commits the drop, or discards it if the finger lifted off the canvas.
    private func commitDrop(_ widget: Widget) {
        guard canvasFrame.contains(widget.coordinate) else {
            pendingDrop = nil
            return
        }

        guard let instance = pendingDrop?.widget else { return }
        layout = layout.inserting(instance, at: canvasPoint(for: widget), in: canvasFrame.size)

        pendingDrop = nil
    }

    /// Converts a global drag location into the canvas' own coordinate space.
    private func canvasPoint(for widget: Widget) -> CGPoint {
        CGPoint(
            x: widget.coordinate.x - canvasFrame.minX,
            y: widget.coordinate.y - canvasFrame.minY
        )
    }

    /// A drop in flight: the widget and the layout it would produce.
    private struct PendingDrop {
        let widget: WidgetInstance
        let layout: WidgetLayout
    }
}

#Preview {
    ContentView()
}
