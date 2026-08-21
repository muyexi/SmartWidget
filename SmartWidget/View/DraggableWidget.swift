import SwiftUI

struct DraggableWidget: View {
    @Binding var widget: Widget
    var onDrag: (Widget) -> Void

    var body: some View {
        ZStack {
            if widget.offset != .zero {
                Circle()
                    .stroke(widget.color.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                    .frame(width: 50, height: 50)
            }

            widget.color
                .frame(width: 50, height: 50)
                .clipShape(Capsule())
                .offset(widget.offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            widget.offset = value.translation
                            widget.coordinate = value.location
                            onDrag(widget)
                        }
                        .onEnded { value in
                            widget.offset = .zero
                            widget.coordinate = value.location
                            onDrag(widget)
                        }
                )
        }
    }
}


#Preview {
    @Previewable @State var widget = Widget(id: 0, color: .red, coordinate: .zero, offset: .zero)

    Group {
        DraggableWidget(widget: $widget, onDrag: { widget in
            print("Point: \(widget.coordinate)")
        })
        .frame(width: 180, height: 180)
    }
}
