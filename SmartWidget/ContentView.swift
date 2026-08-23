import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Spacer()

            dropArea

            Spacer()

            WidgetToolbar(
                isPreviewing: viewModel.isPreviewing,
                onDrag: viewModel.previewDrop,
                onDrop: viewModel.commitDrop
            )
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var dropArea: some View {
        GeometryReader { proxy in
            WidgetCanvasView(layout: viewModel.visibleLayout)
                .onAppear {
                    viewModel.canvasFrame = proxy.frame(in: .global)
                }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
    }
}

#Preview {
    ContentView()
}
