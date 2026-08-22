import CoreGraphics
import Testing
@testable import SmartWidget

/// Question 2 — the layout structure produces the frames we expect.
///
/// A 200×200 canvas keeps every expected value a whole number, so the
/// assertions read as geometry rather than as floating-point arithmetic.
@Suite("WidgetLayout frames")
struct WidgetLayoutFrameTests {
    private let canvas = CGSize(width: 200, height: 200)

    @Test("An empty layout produces no placements")
    func emptyLayout() {
        #expect(WidgetLayout().placements(in: canvas).isEmpty)
    }

    @Test("A lone widget fills the canvas")
    func singleWidgetFillsCanvas() {
        let a = WidgetInstance(color: .skyBlue)
        let placements = WidgetLayout(rows: [[a]]).placements(in: canvas)

        #expect(placements.map(\.frame) == [CGRect(x: 0, y: 0, width: 200, height: 200)])
    }

    @Test("Widgets in one row split its width")
    func rowSplitsWidth() {
        let a = WidgetInstance(color: .skyBlue)
        let b = WidgetInstance(color: .hotPink)
        let placements = WidgetLayout(rows: [[a, b]]).placements(in: canvas)

        #expect(placements.map(\.frame) == [
            CGRect(x: 0, y: 0, width: 100, height: 200),
            CGRect(x: 100, y: 0, width: 100, height: 200),
        ])
    }

    @Test("Rows split the canvas height")
    func rowsSplitHeight() {
        let a = WidgetInstance(color: .skyBlue)
        let b = WidgetInstance(color: .hotPink)
        let placements = WidgetLayout(rows: [[a], [b]]).placements(in: canvas)

        #expect(placements.map(\.frame) == [
            CGRect(x: 0, y: 0, width: 200, height: 100),
            CGRect(x: 0, y: 100, width: 200, height: 100),
        ])
    }

    @Test("Rows of differing widget counts are laid out independently")
    func mixedRows() {
        let a = WidgetInstance(color: .skyBlue)
        let b = WidgetInstance(color: .hotPink)
        let c = WidgetInstance(color: .limeGreen)
        let layout = WidgetLayout(rows: [[a, b], [c]])

        #expect(layout.placements(in: canvas).map(\.frame) == [
            CGRect(x: 0, y: 0, width: 100, height: 100),
            CGRect(x: 100, y: 0, width: 100, height: 100),
            CGRect(x: 0, y: 100, width: 200, height: 100),
        ])
    }

    @Test("Spacing goes between neighbours, never against the canvas edges")
    func spacingSitsBetweenNeighbours() {
        let a = WidgetInstance(color: .skyBlue)
        let b = WidgetInstance(color: .hotPink)
        let layout = WidgetLayout(rows: [[a, b], [WidgetInstance(color: .limeGreen)]])
        let placements = layout.placements(in: canvas, spacing: 20)

        #expect(placements.map(\.frame) == [
            CGRect(x: 0, y: 0, width: 90, height: 90),
            CGRect(x: 110, y: 0, width: 90, height: 90),
            CGRect(x: 0, y: 110, width: 200, height: 90),
        ])
    }

    @Test("Placements come back in reading order")
    func placementsFollowReadingOrder() {
        let a = WidgetInstance(color: .skyBlue)
        let b = WidgetInstance(color: .hotPink)
        let c = WidgetInstance(color: .limeGreen)
        let layout = WidgetLayout(rows: [[a, b], [c]])

        #expect(layout.placements(in: canvas).map(\.id) == [a.id, b.id, c.id])
    }

    @Test("Spacing that leaves no room produces nothing rather than negative frames")
    func spacingLargerThanCanvas() {
        let layout = WidgetLayout(rows: [[WidgetInstance(color: .skyBlue)], [WidgetInstance(color: .hotPink)]])

        #expect(layout.placements(in: canvas, spacing: 400).isEmpty)
    }
}
