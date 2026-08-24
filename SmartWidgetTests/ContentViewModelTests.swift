import CoreGraphics
import SwiftUI
import Testing
@testable import SmartWidget

@MainActor
@Suite("ContentViewModel")
struct ContentViewModelTests {
    private let canvasFrame = CGRect(x: 100, y: 200, width: 200, height: 200)

    @Test("Dragging inside the canvas creates an uncommitted preview")
    func previewInsideCanvas() {
        let viewModel = ContentViewModel(canvasFrame: canvasFrame)

        viewModel.previewDrop(widget(at: CGPoint(x: 200, y: 300)))

        #expect(viewModel.isPreviewing)
        #expect(viewModel.layout.isEmpty)
        #expect(viewModel.visibleLayout.widgets.count == 1)
    }

    @Test("Dragging outside the canvas clears the preview")
    func previewOutsideCanvas() {
        let viewModel = ContentViewModel(canvasFrame: canvasFrame)
        viewModel.previewDrop(widget(at: CGPoint(x: 200, y: 300)))

        viewModel.previewDrop(widget(at: CGPoint(x: 50, y: 300)))

        #expect(!viewModel.isPreviewing)
        #expect(viewModel.visibleLayout.isEmpty)
    }

    @Test("Dragging within the same insertion area keeps the preview unchanged")
    func repeatedPreviewInSameArea() {
        let existing = WidgetInstance(color: .skyBlue)
        let viewModel = ContentViewModel(
            layout: WidgetCanvasLayout(.widget(existing)),
            canvasFrame: canvasFrame
        )

        viewModel.previewDrop(widget(at: CGPoint(x: 250, y: 300)))
        let previewLayout = viewModel.visibleLayout

        viewModel.previewDrop(widget(at: CGPoint(x: 260, y: 300)))

        #expect(viewModel.visibleLayout == previewLayout)
    }

    @Test("Global drag coordinates are converted before resolving insertion")
    func convertsToCanvasCoordinates() {
        let existing = WidgetInstance(color: .skyBlue)
        let viewModel = ContentViewModel(
            layout: WidgetCanvasLayout(.widget(existing)),
            canvasFrame: canvasFrame
        )

        // Global (150, 300) is canvas (50, 100): the leading side of the widget
        // already there. Left unconverted it would read as a drop below the
        // canvas, and land underneath instead.
        viewModel.previewDrop(widget(at: CGPoint(x: 150, y: 300)))

        #expect(viewModel.visibleLayout.widgets.count == 2)
        #expect(viewModel.visibleLayout.widgets.last?.id == existing.id)
        #expect(viewModel.visibleLayout.placements(in: canvasFrame.size).map(\.frame) == [
            CGRect(x: 0, y: 0, width: 100, height: 200),
            CGRect(x: 100, y: 0, width: 100, height: 200),
        ])
    }

    @Test("Committing preserves the previewed widget identity")
    func commitPreview() {
        let viewModel = ContentViewModel(canvasFrame: canvasFrame)
        let draggedWidget = widget(at: CGPoint(x: 200, y: 300))
        viewModel.previewDrop(draggedWidget)
        let previewID = viewModel.visibleLayout.widgets.first?.id

        viewModel.commitDrop(draggedWidget)

        #expect(!viewModel.isPreviewing)
        #expect(viewModel.layout.widgets.first?.id == previewID)
    }

    private func widget(at coordinate: CGPoint) -> SmartWidget.DraggableWidget {
        SmartWidget.DraggableWidget(id: 0, color: .hotPink, coordinate: coordinate, offset: .zero)
    }
}
