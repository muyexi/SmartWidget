import Observation
import SwiftUI

@Observable
final class ContentViewModel {
    private(set) var canvas: WidgetCanvas
    private var pendingDrop: PendingDrop?

    var canvasFrame: CGRect

    var visibleCanvas: WidgetCanvas {
        pendingDrop?.canvas ?? canvas
    }

    var isPreviewing: Bool {
        pendingDrop != nil
    }

    init(canvas: WidgetCanvas = WidgetCanvas(), canvasFrame: CGRect = .zero) {
        self.canvas = canvas
        self.canvasFrame = canvasFrame
    }

    func previewDrop(_ widget: DraggableWidget) {
        guard canvasFrame.contains(widget.coordinate) else {
            if pendingDrop != nil {
                pendingDrop = nil
            }
            return
        }

        let instance = pendingDrop?.widget ?? WidgetInstance(color: widget.color)
        let previewCanvas = canvas.inserting(
            instance,
            at: canvasPoint(for: widget),
            in: canvasFrame.size
        )

        guard pendingDrop?.canvas != previewCanvas else { return }
        pendingDrop = PendingDrop(widget: instance, canvas: previewCanvas)
    }

    func commitDrop(_ widget: DraggableWidget) {
        guard canvasFrame.contains(widget.coordinate) else {
            pendingDrop = nil
            return
        }

        guard let instance = pendingDrop?.widget else { return }
        canvas = canvas.inserting(
            instance,
            at: canvasPoint(for: widget),
            in: canvasFrame.size
        )

        pendingDrop = nil
    }

    private func canvasPoint(for widget: DraggableWidget) -> CGPoint {
        CGPoint(
            x: widget.coordinate.x - canvasFrame.minX,
            y: widget.coordinate.y - canvasFrame.minY
        )
    }

    private struct PendingDrop {
        let widget: WidgetInstance
        let canvas: WidgetCanvas
    }
}
