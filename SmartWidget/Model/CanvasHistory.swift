struct CanvasHistory: Equatable {
    private(set) var current: WidgetCanvas
    private var past: [WidgetCanvas]
    private var future: [WidgetCanvas]

    var canUndo: Bool {
        !past.isEmpty
    }

    var canRedo: Bool {
        !future.isEmpty
    }

    var canClear: Bool {
        !current.isEmpty
    }

    init(current: WidgetCanvas = WidgetCanvas()) {
        self.current = current
        past = []
        future = []
    }

    mutating func commit(_ canvas: WidgetCanvas) {
        past.append(current)
        current = canvas
        future.removeAll()
    }

    mutating func undo() {
        guard let previous = past.popLast() else { return }
        future.append(current)
        current = previous
    }

    mutating func redo() {
        guard let next = future.popLast() else { return }
        past.append(current)
        current = next
    }

    mutating func clear() {
        current = WidgetCanvas()
        past.removeAll()
        future.removeAll()
    }
}
