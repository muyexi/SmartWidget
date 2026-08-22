import SwiftUI

struct WidgetWelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("👋")
                .font(.system(size: 60))
                .fontWeight(.bold)
            Text("Hi! \nDrag and drop your widgets to unleash your creativity!")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(lineWidth: 4, dash: [6, 3])
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("canvas.welcome")
    }
}

#Preview {
    VStack {
        WidgetWelcomeView()
    }
    .aspectRatio(1.0, contentMode: .fit)
}
