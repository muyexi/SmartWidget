import SwiftUI
import Testing
@testable import SmartWidget

@Suite("CanvasHistory")
struct CanvasHistoryTests {
    @Test("Undo and redo move between committed canvases")
    func undoAndRedo() {
        let first = canvas(color: .skyBlue)
        let second = canvas(color: .hotPink)
        var history = CanvasHistory()

        history.commit(first)
        history.commit(second)

        #expect(history.current == second)
        #expect(history.canUndo)
        #expect(!history.canRedo)

        history.undo()

        #expect(history.current == first)
        #expect(history.canUndo)
        #expect(history.canRedo)

        history.redo()

        #expect(history.current == second)
        #expect(history.canUndo)
        #expect(!history.canRedo)
    }

    @Test("A new commit after undo abandons the redo branch")
    func commitAfterUndo() {
        let first = canvas(color: .skyBlue)
        let abandoned = canvas(color: .hotPink)
        let replacement = canvas(color: .limeGreen)
        var history = CanvasHistory()
        history.commit(first)
        history.commit(abandoned)
        history.undo()

        history.commit(replacement)

        #expect(history.current == replacement)
        #expect(!history.canRedo)
        history.redo()
        #expect(history.current == replacement)
    }

    @Test("Clear empties the canvas and both history stacks")
    func clear() {
        let first = canvas(color: .skyBlue)
        let second = canvas(color: .hotPink)
        var history = CanvasHistory()
        history.commit(first)
        history.commit(second)
        history.undo()

        history.clear()

        #expect(history.current.isEmpty)
        #expect(!history.canUndo)
        #expect(!history.canRedo)
        #expect(!history.canClear)

        history.undo()
        history.redo()
        #expect(history.current.isEmpty)
    }

    @Test("Undo and redo do nothing at their boundaries")
    func boundaryNoOps() {
        var history = CanvasHistory()

        history.undo()
        history.redo()

        #expect(history.current.isEmpty)
        #expect(!history.canUndo)
        #expect(!history.canRedo)
    }

    private func canvas(color: Color) -> WidgetCanvas {
        WidgetCanvas(.widget(WidgetInstance(color: color)))
    }
}
