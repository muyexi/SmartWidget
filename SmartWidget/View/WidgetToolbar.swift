import SwiftUI

struct WidgetToolbar: View {
    let colors: [Color] = [
        .skyBlue,
        .hotPink,
        .brightYellow,
        .limeGreen,
        .vibrantOrange
    ]
    
    @State private var offsets: [CGSize] = []
    var onDrop: (Color, CGPoint) -> Void
    
    init(onDrop: @escaping (Color, CGPoint) -> Void = { _,_ in }) {
        self.onDrop = onDrop
        _offsets = State(initialValue: Array(repeating: .zero, count: colors.count))
    }

    var body: some View {
        HStack {
            ForEach(colors.indices, id: \.self) { index in
                DraggableWidget(color: colors[index], offset: $offsets[index], onDrop: onDrop)
                
                // Add equal spacing between elements.
                if index < colors.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white)
                .appShadow()
        )
    }
}

#Preview {
    WidgetToolbar()
}
