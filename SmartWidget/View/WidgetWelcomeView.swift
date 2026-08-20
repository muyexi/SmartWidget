import SwiftUI

struct WidgetWelcomeView: View {
    var body: some View {
        VStack(alignment: .center) {
            VStack(spacing: 20) {
                Text("👋")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                Text("Hi! \nDrag and drop your widgets to unleash your creativity!")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(style: StrokeStyle(lineWidth: 4, dash: [6, 3]))
                .foregroundStyle(Color.gray.opacity(0.2))
        )
    }
}

#Preview {
    WidgetWelcomeView()
}

