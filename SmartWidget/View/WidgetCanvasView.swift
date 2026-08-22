import SwiftUI

struct WidgetCanvasView: View {
    let instances: [WidgetInstance]

    private let spacing: CGFloat = 5
    private let cornerRadius: CGFloat = 24

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ForEach(Array(instances.enumerated()), id: \.element.id) { index, widget in
                    widget.color
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .appShadow()
                        .frame(width: instances[index].frame.width, height: instances[index].frame.height)
                        .position(x: instances[index].frame.midX, y: instances[index].frame.midY)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: instances.count)
    }
}

#Preview {
    WidgetCanvasView(instances: [.init(color: .skyBlue, frame: .init(x: 0, y: 0, width: 300, height: 300))])
        .frame(width: 300, height: 300)
        .padding()
}
