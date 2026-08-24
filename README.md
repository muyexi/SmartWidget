# SmartWidget

A SwiftUI proof of concept for a customizable widget layout system, built for the trading-system UI brief in `Requirement.pdf`.

Drag a coloured button up from the palette and drop it onto the canvas. The canvas is a live tiling layout: the widget you release onto decides what happens — drop on its top or bottom quarter and the newcomer stacks above or below it, drop anywhere else and it sits beside it.

## Requirements

| | |
|---|---|
| iOS deployment target | 17 (app target) |
| Language / UI | Swift 5, SwiftUI |
| Dependencies | none |

## Running

```bash
open SmartWidget.xcodeproj
```

## How it works

1. **Empty canvas.** A dashed square with a 👋 greeting fills the upper part of the screen. Five 50pt circular buttons sit in a floating capsule bar at the bottom.
2. **Dragging.** Picking up a button lifts it with a shadow and leaves a dashed circle in its slot in the palette.
3. **Live preview.** As soon as the finger crosses into the canvas, the canvas shows the layout *as it would be* if you let go right now — the new tile springs in and the existing tiles make room. The dragged chip fades out at that moment. Move around and the preview keeps re-resolving; move back out and it disappears again.
4. **Drop.** Releasing inside the canvas commits the previewed layout. Releasing outside discards it, and nothing changes.

## Project structure

```
SmartWidget/
├── SmartWidgetApp.swift          App entry point
├── ContentView.swift             Canvas + palette; reports canvas geometry to the view model
├── Model/
│   ├── WidgetInstance.swift      One placed widget: identity + colour
│   ├── WidgetCanvas.swift        The layout engine (Q1–Q3): a tree of nodes
│   └── DraggableWidget.swift     A palette button and its in-flight drag state
├── ViewModel/
│   └── ContentViewModel.swift    Preview vs. commit; global → canvas coordinate conversion
├── View/
│   ├── WidgetCanvasView.swift    The drop area, tiles, animations
│   ├── WidgetTileLayout.swift    A SwiftUI `Layout` that places tiles from the engine's frames
│   ├── WidgetToolbar.swift       The palette bar
│   ├── WidgetWelcomeView.swift   The empty-canvas greeting
│   └── DraggableWidgetView.swift The drag gesture and its feedback
└── Extension/                    Colour palette, app shadow
```
