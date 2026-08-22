import SwiftUI

struct DraggableWidgetView: View {
    @Binding var widget: Widget
    let isPreviewing: Bool

    var onDrag: (Widget) -> Void = { _ in }
    var onDrop: (Widget) -> Void = { _ in }

    private var isDragging: Bool {
        widget.offset != .zero
    }

    var body: some View {
        ZStack {
            if isDragging {
                Circle()
                    .stroke(widget.color.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
            }

            widget.color
                .clipShape(Capsule())
                .appShadow(isDragging)
                .offset(widget.offset)
                .opacity(isDragging && isPreviewing ? 0 : 1)
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            widget.offset = value.translation
                            widget.coordinate = value.location
                            onDrag(widget)
                        }
                        .onEnded { value in
                            widget.offset = .zero
                            widget.coordinate = value.location
                            onDrop(widget)
                        }
                )
        }
        .frame(width: 50, height: 50)
        .accessibilityIdentifier("palette.button.\(widget.id)")
    }
}

#Preview {
    @Previewable @State var widget = Widget(id: 0, color: .red, coordinate: .zero, offset: .zero)

    DraggableWidgetView(
        widget: $widget,
        isPreviewing: false,
        onDrag: { print("dragging at \($0.coordinate)") },
        onDrop: { print("dropped at \($0.coordinate)") }
    )
    .frame(width: 180, height: 180)
}
