import XCTest

/// End-to-end checks that the gesture, the layout engine and the canvas agree.
///
/// The unit tests already prove the engine puts widgets in the right slot; these
/// prove a real finger reaches it — that the drop point converts into canvas
/// space correctly and that the resulting frames land where the layout says.
final class WidgetDragAndDropUITests: XCTestCase {
    private var app: XCUIApplication!

    /// The canvas rectangle in screen coordinates, measured once from the
    /// greeting while the canvas is still empty and untouched. The canvas is a
    /// fixed-aspect container that never moves, so one reading serves the whole
    /// test — and it cannot be thrown off by a view mid-transition.
    private var canvas: CGRect = .zero

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        XCTAssertTrue(welcome.waitForExistence(timeout: 5), "The app should start on an empty canvas")
        canvas = welcome.frame
    }

    // MARK: - Helpers

    /// SwiftUI decides for itself which accessibility element type a view
    /// becomes, so every lookup here matches on identifier alone.
    ///
    /// The identifiers are string literals on both sides. A UI test bundle
    /// cannot import the app module, so there is no shared constant to refer
    /// to — renaming one means renaming the other.
    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    /// The greeting shown while the canvas is empty; also the canvas' own bounds.
    private var welcome: XCUIElement { element("canvas.welcome") }

    private var tiles: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "canvas.tile")
    }

    private func paletteButton(_ index: Int) -> XCUIElement {
        element("palette.button.\(index)")
    }

    /// Drags palette button `index` to a point given as a fraction of the canvas.
    private func drag(_ index: Int, toRelative relative: CGPoint) {
        let target = app.coordinate(withNormalizedOffset: .zero).withOffset(
            CGVector(
                dx: canvas.minX + canvas.width * relative.x,
                dy: canvas.minY + canvas.height * relative.y
            )
        )
        let source = paletteButton(index).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        // A slow drag with a hold at the end: SwiftUI needs intermediate touch
        // events to build a preview, and a moment to settle before we measure.
        source.press(forDuration: 0.1, thenDragTo: target, withVelocity: .slow, thenHoldForDuration: 0.3)
        // Let the placement spring settle before anything measures a frame.
        Thread.sleep(forTimeInterval: 0.8)
    }

    // MARK: - Tests

    func testInitialScreenShowsGreetingAndFivePaletteButtons() {
        XCTAssertTrue(welcome.exists, "The greeting should show on an empty canvas")
        for index in 0..<5 {
            XCTAssertTrue(paletteButton(index).exists, "Palette button \(index) should exist")
        }
        XCTAssertEqual(tiles.count, 0, "Nothing should be placed yet")
    }

    func testDroppingOneWidgetFillsTheCanvasAndHidesTheGreeting() {
        drag(0, toRelative: CGPoint(x: 0.5, y: 0.5))

        XCTAssertEqual(tiles.count, 1)
        XCTAssertTrue(welcome.waitForNonExistence(timeout: 2), "The greeting should give way to the layout")

        let tile = tiles.element(boundBy: 0).frame
        XCTAssertEqual(tile.width, canvas.width, accuracy: 2, "A lone widget spans the canvas width")
        XCTAssertEqual(tile.height, canvas.height, accuracy: 2, "A lone widget spans the canvas height")
    }

    func testDroppingOnTheRightHalfPlacesTheWidgetBesideTheFirst() {
        drag(0, toRelative: CGPoint(x: 0.5, y: 0.5))
        drag(1, toRelative: CGPoint(x: 0.8, y: 0.5))

        XCTAssertEqual(tiles.count, 2)

        let frames = (0..<2).map { tiles.element(boundBy: $0).frame }.sorted { $0.minX < $1.minX }
        XCTAssertEqual(frames[0].height, canvas.height, accuracy: 2, "Both stay in one row")
        XCTAssertEqual(frames[1].height, canvas.height, accuracy: 2)
        XCTAssertLessThan(frames[0].maxX, frames[1].minX, "They sit side by side, not overlapping")
        XCTAssertEqual(frames[0].width, frames[1].width, accuracy: 2, "A row splits its width evenly")
    }

    func testDroppingNearTheBottomEdgeStartsANewRow() {
        drag(0, toRelative: CGPoint(x: 0.5, y: 0.5))
        drag(1, toRelative: CGPoint(x: 0.5, y: 0.95))

        XCTAssertEqual(tiles.count, 2)

        let frames = (0..<2).map { tiles.element(boundBy: $0).frame }.sorted { $0.minY < $1.minY }
        XCTAssertLessThan(frames[0].maxY, frames[1].minY, "The second widget sits below the first")
        XCTAssertEqual(frames[0].width, canvas.width, accuracy: 2, "Each row still spans the full width")
        XCTAssertEqual(frames[1].width, canvas.width, accuracy: 2)
    }

    func testRowsAndColumnsCombine() {
        drag(0, toRelative: CGPoint(x: 0.5, y: 0.5))   // one row: [A]
        drag(1, toRelative: CGPoint(x: 0.8, y: 0.5))   // one row: [A, B]
        drag(2, toRelative: CGPoint(x: 0.5, y: 0.95))  // two rows: [A, B], [C]

        XCTAssertEqual(tiles.count, 3)

        let frames = (0..<3).map { tiles.element(boundBy: $0).frame }
        let topRow = frames.filter { $0.minY < frames.map(\.minY).max()! }
        let bottomRow = frames.filter { $0.minY == frames.map(\.minY).max()! }

        XCTAssertEqual(topRow.count, 2, "Two widgets share the top row")
        XCTAssertEqual(bottomRow.count, 1, "The third has a row to itself")
        XCTAssertGreaterThan(bottomRow[0].width, topRow[0].width, "A lone widget in a row is wider")
    }

    func testDroppingOutsideTheCanvasPlacesNothing() {
        let button = paletteButton(0)
        // Drag sideways along the toolbar and release — never over the canvas.
        button.press(forDuration: 0.1, thenDragTo: paletteButton(4), withVelocity: .slow, thenHoldForDuration: 0.3)

        XCTAssertEqual(tiles.count, 0, "A drop outside the canvas is discarded")
        XCTAssertTrue(welcome.exists, "The greeting stays put")
    }
}
