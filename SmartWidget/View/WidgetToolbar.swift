import SwiftUI

struct WidgetToolbar: View {
    @State private var widgets: [Widget]
    var onDrag: (Widget) -> Void
    var onDrop: (Widget) -> Void

    init(
        widgets: [Widget] = Widget.toolbarItems,
        onDrag: @escaping (Widget) -> Void = { _ in },
        onDrop: @escaping (Widget) -> Void = { _ in }
    ) {
        self.onDrag = onDrag
        self.onDrop = onDrop
        _widgets = State(initialValue: widgets)
    }

    var body: some View {
        HStack {
            ForEach(widgets.indices, id: \.self) { index in
                DraggableWidgetView(widget: $widgets[index], onDrag: onDrag, onDrop: onDrop)

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
