import SwiftUI

struct WidgetToolbar: View {
    @State private var widgets: [DraggableWidget] = DraggableWidget.toolbarItems
    var isPreviewing: Bool = false
    var onDrag: (DraggableWidget) -> Void = { _ in }
    var onDrop: (DraggableWidget) -> Void = { _ in }

    var body: some View {
        HStack {
            ForEach(widgets.indices, id: \.self) { index in
                DraggableWidgetView(
                    widget: $widgets[index],
                    isPreviewing: isPreviewing,
                    onDrag: onDrag,
                    onDrop: onDrop
                )

                // Add equal spacing between elements.
                if index < widgets.count - 1 {
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
