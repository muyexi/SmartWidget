import SwiftUI

struct GreetingView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            Text("👋")
                .font(.system(size: 60))
                .fontWeight(.bold)
                .phaseAnimator([0.0, -10.0, 18.0, -8.0, 14.0, -4.0, 0.0]) { hand, angle in
                    hand.rotationEffect(.degrees(angle), anchor: .bottomTrailing)
                } animation: { angle in
                    switch angle {
                    case -10:
                        .easeInOut(duration: 0.18).delay(1.6)
                    case 0:
                        .easeOut(duration: 0.18)
                    default:
                        .easeInOut(duration: 0.14)
                    }
                }

            Text("Hi! \nDrag and drop your widgets to unleash your creativity!")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
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
        GreetingView()
    }
    .aspectRatio(1.0, contentMode: .fit)
}
