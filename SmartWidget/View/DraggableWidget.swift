import SwiftUI

struct DraggableWidget: View {
    let color: Color
    @Binding var offset: CGSize
    var onDrop: (Color, CGPoint) -> Void

    var body: some View {
        ZStack {
            if offset != .zero {
                Circle()
                    .stroke(color.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                    .frame(width: 50, height: 50)
            }

            color
                .frame(width: 50, height: 50)
                .clipShape(Capsule())
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                        .onEnded { value in
                            onDrop(color, value.location)
                            offset = .zero
                        }
                )
        }
    }
}


#Preview {
    @Previewable @State var offset: CGSize = .zero

    Group {
        DraggableWidget(color: .red, offset: $offset, onDrop: { _, point in
            print("Point: \(point)")
        })
        .frame(width: 180, height: 180)
    }
}
