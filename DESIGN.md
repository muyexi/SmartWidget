# DESIGN

The short version: **the layout is a tree, everything else is derived from it.** Frames are
computed from the tree, a drop is a pure tree → tree function. There is no second source of truth to keep in sync.

---

## Contents

- [Q1 — The data structure](#q1--the-data-structure)
- [Q2 — Computing each widget's frame](#q2--computing-each-widgets-frame)
- [Q3 — Resolving a drop, without side effects](#q3--resolving-a-drop-without-side-effects)
- [Q4 — Wiring it into a working app](#q4--wiring-it-into-a-working-app)
- [Testing strategy](#testing-strategy)

---

## Q1 — The data structure

> *What kind of data structure is needed to represent the layout of a widget?*

**A tree of nodes.** A node is either a single widget, or a container that divides its area evenly
among its children — left to right (a row) or top to bottom (a column).

```swift
struct WidgetCanvas: Equatable {
    private(set) var root: Node?

    enum Axis { case horizontal, vertical }

    indirect enum Node: Equatable {
        case widget(WidgetInstance)
        case container(axis: Axis, children: [Node])
    }
}
```

So this canvas:

```
┌─────────┬─────────┐
│         │    b    │
│    a    ├─────────┤
│         │    c    │
└─────────┴─────────┘
```

is exactly this value:

```swift
WidgetCanvas(.row(.widget(a), .column(.widget(b), .widget(c))))
```

---

## Q2 — Computing each widget's frame

> *Implement a process to calculate the frame of each widget based on the data from Question 1.*

[`WidgetCanvas.placements(in:spacing:)`](SmartWidget/Model/WidgetCanvas.swift):

```swift
func placements(in size: CGSize, spacing: CGFloat = 0) -> [Placement]

struct Placement: Identifiable, Equatable {
    var id: UUID { widget.id }
    let widget: WidgetInstance
    let frame: CGRect
}
```

One rule, applied recursively: **a container hands each child an equal share of its own rectangle;
a widget fills the rectangle it is handed.** The recursion carries a `CGRect` down the tree and
returns placements up.

Design points worth naming:

- **Placements are derived, never stored.** They are rebuilt on every layout pass.
- **Depth-first order is a contract.** `placements(in:)` and `WidgetCanvas.widgets` walk the tree
  the same way, so the *n*th placement always describes the *n*th widget. 
- **The engine returns geometry, the view applies it.** `placements` returns rects in canvas-local
  coordinates with the origin at the top-left; `WidgetTileLayout.placeSubviews` offsets them by
  `bounds.origin`. The engine never needs to know where on screen the canvas sits.

---

## Q3 — Resolving a drop, without side effects

> *Implement a function that calculates how the data changes when a widget is dropped at a given
> coordinate. It must have no side effects, and have unit tests.*

The signature is exactly the one in the brief — *data before + coordinate + widget → data after*:

```swift
func inserting(_ widget: WidgetInstance, at point: CGPoint, in size: CGSize) -> WidgetCanvas
```

It is a `func` on a `struct` that is **not** `mutating` and returns a new value. `Node` is an enum
of value types, so the result shares nothing mutable with the receiver: calling it cannot affect the
canvas it was called on, and there is nowhere for a side effect to hide. Two tests pin this down
directly (`insertingIsPure`, `insertingIsDeterministic`).

### The rules, in order

1. **Empty canvas** → the widget becomes the whole canvas.
2. **Otherwise, descend.** At each container, `childIndex(for:along:in:count:)` picks the slice the
   point falls in, and the search recurses into that child with that slice as its rectangle.
3. **At the widget under the point**, ask which of its four sides the point is nearest to, and make
   the newcomer that widget's sibling on that side via `splitting` — which, per Q1, either joins the
   surrounding container or nests a new one.

---

## Q4 — Wiring it into a working app

> *Using Questions 1–3, implement a solution that meets the requirements.*

### The drag pipeline

```
DraggableWidgetView          ContentViewModel                 WidgetCanvasView
──────────────────           ────────────────                 ────────────────
DragGesture(.global)
  .onChanged  ──────────▶  previewDrop(widget)
                             ├ outside canvasFrame → pendingDrop = nil
                             └ inside → canvas.inserting(…)  ──▶  visibleCanvas
                                        stored as pendingDrop      (animated)
  .onEnded    ──────────▶  commitDrop(widget)
                             ├ outside → pendingDrop = nil (discard)
                             └ inside → canvas = canvas.inserting(…)
```

---

## Testing strategy

Two layers, testing two different claims.

**28 unit tests** (Swift Testing) — *the geometry is right.*

| Suite | Covers |
|---|---|
| [`WidgetCanvasFrameTests`](SmartWidgetTests/WidgetCanvasFrameTests.swift) (7) | Q2: empty layouts, a lone widget, row/column division, *n*-way even splits, nesting, spacing. |
| [`WidgetCanvasDropTests`](SmartWidgetTests/WidgetCanvasDropTests.swift) (16) | Q3: the empty canvas, all four edges, fraction-based edge choice, joining an existing row/column, nesting without disturbing siblings, out-of-bounds clamping on every side, purity, determinism. |
| [`ContentViewModelTests`](SmartWidgetTests/ContentViewModelTests.swift) (5) | Preview creation, preview cancellation on leaving the canvas, preview de-duplication, global→canvas conversion, commit. |

**5 UI tests** (XCTest) — *a real finger reaches that geometry.*

[`WidgetDragAndDropUITests`](SmartWidgetUITests/WidgetDragAndDropUITests.swift) performs actual
drags on the simulator and asserts the resulting on-screen frames match what the engine promises:
the initial screen, a single widget filling the canvas, a side-by-side drop splitting the width
evenly, a bottom-edge drop stacking, and a drop outside the canvas changing nothing.

---
