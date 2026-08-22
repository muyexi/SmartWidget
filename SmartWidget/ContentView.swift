import SwiftUI

struct ContentView: View {
    @State private var instances: [WidgetInstance] = []
    @State private var dropFrame: CGRect = .zero
    
    var body: some View {
        VStack {
            Spacer()

            dropArea

            Spacer()
            WidgetToolbar(
                onDrag: handleWidgetDrag
            )
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var dropArea: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)

            VStack {
                if instances.isEmpty {
                    WidgetWelcomeView()
                } else {
                    WidgetCanvasView(instances: instances)
                }
            }
            .onAppear {
                dropFrame = frame
            }
            .onChange(of: frame) { _, newFrame in
                dropFrame = newFrame
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
    }

    private func handleWidgetDrag(_ widget: Widget) {
        guard dropFrame.contains(widget.coordinate) else {
            instances.removeAll { $0.isPreview }
            return
        }

        let isPreview = widget.offset != .zero
        let dropAreaInstanceFrame = CGRect(origin: .zero, size: dropFrame.size)

        if let previewIndex = instances.firstIndex(where: \.isPreview) {
            instances[previewIndex].isPreview = isPreview
            instances[previewIndex].frame = dropAreaInstanceFrame
        } else {
            instances.append(WidgetInstance(color: widget.color, isPreview: isPreview, frame: dropAreaInstanceFrame))
        }
    }
}

#Preview {
    ContentView()
}
