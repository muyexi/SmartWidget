import Observation
import SwiftUI

@Observable
final class ContentViewModel {
    private(set) var layout: WidgetLayout
    private var pendingDrop: PendingDrop?

    var canvasFrame: CGRect

    var visibleLayout: WidgetLayout {
        pendingDrop?.layout ?? layout
    }

    var isPreviewing: Bool {
        pendingDrop != nil
    }

    init(layout: WidgetLayout = WidgetLayout(), canvasFrame: CGRect = .zero) {
        self.layout = layout
        self.canvasFrame = canvasFrame
    }

    func previewDrop(_ widget: Widget) {
        guard canvasFrame.contains(widget.coordinate) else {
            pendingDrop = nil
            return
        }

        let instance = pendingDrop?.widget ?? WidgetInstance(color: widget.color)
        let previewLayout = layout.inserting(
            instance,
            at: canvasPoint(for: widget),
            in: canvasFrame.size
        )

        pendingDrop = PendingDrop(widget: instance, layout: previewLayout)
    }

    func commitDrop(_ widget: Widget) {
        guard canvasFrame.contains(widget.coordinate) else {
            pendingDrop = nil
            return
        }

        guard let instance = pendingDrop?.widget else { return }
        layout = layout.inserting(
            instance,
            at: canvasPoint(for: widget),
            in: canvasFrame.size
        )

        pendingDrop = nil
    }

    private func canvasPoint(for widget: Widget) -> CGPoint {
        CGPoint(
            x: widget.coordinate.x - canvasFrame.minX,
            y: widget.coordinate.y - canvasFrame.minY
        )
    }

    private struct PendingDrop {
        let widget: WidgetInstance
        let layout: WidgetLayout
    }
}
