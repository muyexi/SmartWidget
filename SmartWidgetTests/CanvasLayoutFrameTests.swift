import CoreGraphics
import Testing
@testable import SmartWidget

/// Question 2 — the layout tree produces the frames we expect.
///
/// A 200×200 canvas keeps the expected values whole wherever the container is even,
/// so the assertions read as geometry rather than as floating-point arithmetic.
@Suite("WidgetCanvasLayout frames")
struct CanvasLayoutFrameTests {
    private let canvas = CGSize(width: 200, height: 200)

    private let a = WidgetInstance(color: .skyBlue)
    private let b = WidgetInstance(color: .hotPink)
    private let c = WidgetInstance(color: .limeGreen)
    private let d = WidgetInstance(color: .brightYellow)

    @Test("An empty layout produces no placements")
    func emptyLayout() {
        #expect(WidgetCanvasLayout().placements(in: canvas).isEmpty)
    }

    @Test("A lone widget fills the canvas")
    func singleWidgetFillsCanvas() {
        let placements = WidgetCanvasLayout(.widget(a)).placements(in: canvas)

        #expect(placements.map(\.frame) == [CGRect(x: 0, y: 0, width: 200, height: 200)])
    }

    @Test("A row splits the width")
    func rowSplitsWidth() {
        let placements = WidgetCanvasLayout(.row(.widget(a), .widget(b))).placements(in: canvas)

        #expect(placements.map(\.frame) == [
            CGRect(x: 0, y: 0, width: 100, height: 200),
            CGRect(x: 100, y: 0, width: 100, height: 200),
        ])
    }

    @Test("A column splits the height")
    func columnSplitsHeight() {
        let placements = WidgetCanvasLayout(.column(.widget(a), .widget(b))).placements(in: canvas)

        #expect(placements.map(\.frame) == [
            CGRect(x: 0, y: 0, width: 200, height: 100),
            CGRect(x: 0, y: 100, width: 200, height: 100),
        ])
    }

    @Test("Every child of a container gets an equal share, however many there are")
    func splitDividesEvenly() {
        let layout = WidgetCanvasLayout(.column(.widget(a), .widget(b), .widget(c), .widget(d)))

        #expect(layout.placements(in: canvas).map(\.frame) == [
            CGRect(x: 0, y: 0, width: 200, height: 50),
            CGRect(x: 0, y: 50, width: 200, height: 50),
            CGRect(x: 0, y: 100, width: 200, height: 50),
            CGRect(x: 0, y: 150, width: 200, height: 50),
        ])
    }

    // MARK: Nesting — the shape a flat list of rows could not express

    @Test("A branch subdivides its own area, leaving its siblings alone")
    func nestedSplitStaysWithinItsBranch() {
        let layout = WidgetCanvasLayout(
            .row(.widget(a), .column(.widget(b), .widget(c)))
        )

        #expect(layout.placements(in: canvas).map(\.frame) == [
            CGRect(x: 0, y: 0, width: 100, height: 200),
            CGRect(x: 100, y: 0, width: 100, height: 100),
            CGRect(x: 100, y: 100, width: 100, height: 100),
        ])
    }

    @Test("A container nested in one that divides the same way is absorbed into it")
    func sameAxisSplitsFlatten() {
        let nested = WidgetCanvasLayout(.row(.widget(a), .row(.widget(b), .widget(c))))
        let flat = WidgetCanvasLayout(.row(.widget(a), .widget(b), .widget(c)))

        #expect(nested == flat)
        #expect(nested.placements(in: canvas).map(\.frame).first?.width == canvas.width / 3)
    }
}
