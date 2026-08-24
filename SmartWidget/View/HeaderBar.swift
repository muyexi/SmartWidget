import SwiftUI

struct HeaderBar: View {
    var canUndo: Bool
    var canRedo: Bool
    var canClear: Bool
    var onUndo: () -> Void
    var onRedo: () -> Void
    var onClear: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            
            button(
                systemName: "arrow.uturn.backward",
                accessibilityLabel: "Undo",
                accessibilityIdentifier: "header.undo",
                isEnabled: canUndo,
                action: onUndo
            )

            button(
                systemName: "arrow.uturn.forward",
                accessibilityLabel: "Redo",
                accessibilityIdentifier: "header.redo",
                isEnabled: canRedo,
                action: onRedo
            )

            button(
                systemName: "trash",
                accessibilityLabel: "Clear",
                accessibilityIdentifier: "header.clear",
                isEnabled: canClear,
                action: onClear
            )
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }

    private func button(
        systemName: String,
        accessibilityLabel: String,
        accessibilityIdentifier: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
        .disabled(!isEnabled)
    }
}

#Preview("Enabled") {
    HeaderBar(
        canUndo: true,
        canRedo: true,
        canClear: true,
        onUndo: {},
        onRedo: {},
        onClear: {}
    )
    .padding()
}

#Preview("Disabled") {
    HeaderBar(
        canUndo: false,
        canRedo: false,
        canClear: false,
        onUndo: {},
        onRedo: {},
        onClear: {}
    )
    .padding()
}
