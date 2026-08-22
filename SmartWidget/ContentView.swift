import SwiftUI

struct ContentView: View {
    @State private var layout = WidgetLayout()

    /// The canvas rectangle in global coordinates, used to convert the drag
    /// gesture's global location into the canvas' own space.
    @State private var canvasFrame: CGRect = .zero

    /// The drop currently being previewed, if any.
    @State private var pendingDrop: PendingDrop?

    /// A drop in flight: the layout it would produce, and which widget in that
    /// layout is the one under the finger.
    private struct PendingDrop {
        let layout: WidgetLayout
        let widget: WidgetInstance
    }

    /// What to draw: the previewed layout while dragging, otherwise the real one.
    private var visibleLayout: WidgetLayout {
        pendingDrop?.layout ?? layout
    }

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
            let frame = proxy.frame(in: .global)

            WidgetCanvasView(layout: visibleLayout)
                .onAppear { canvasFrame = frame }
                .onChange(of: frame) { _, newFrame in canvasFrame = newFrame }
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

        // Reuse the instance across the whole gesture so its tile keeps a stable
        // identity and animates as the finger moves, instead of being rebuilt.
        let instance = pendingDrop?.widget ?? WidgetInstance(color: widget.color)
        pendingDrop = PendingDrop(
            layout: layout.inserting(instance, at: canvasPoint(for: widget), in: canvasFrame.size),
            widget: instance
        )
    }

    /// Commits the drop, or discards it if the finger lifted off the canvas.
    private func commitDrop(_ widget: Widget) {
        defer { pendingDrop = nil }

        guard canvasFrame.contains(widget.coordinate) else { return }

        let instance = pendingDrop?.widget ?? WidgetInstance(color: widget.color)
        layout = layout.inserting(instance, at: canvasPoint(for: widget), in: canvasFrame.size)
    }

    /// Converts a global drag location into the canvas' own coordinate space.
    private func canvasPoint(for widget: Widget) -> CGPoint {
        CGPoint(
            x: widget.coordinate.x - canvasFrame.minX,
            y: widget.coordinate.y - canvasFrame.minY
        )
    }
}

#Preview {
    ContentView()
}
