import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            HeaderBar(
                canUndo: viewModel.canUndo,
                canRedo: viewModel.canRedo,
                canClear: viewModel.canClear,
                onUndo: viewModel.undo,
                onRedo: viewModel.redo,
                onClear: viewModel.clear
            )

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
        WidgetCanvasView(canvas: viewModel.visibleCanvas)
            .frame(maxWidth: .infinity)
            .aspectRatio(1.0, contentMode: .fit)
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { canvasFrame in
                viewModel.canvasFrame = canvasFrame
            }
    }
}

#Preview {
    ContentView()
}
