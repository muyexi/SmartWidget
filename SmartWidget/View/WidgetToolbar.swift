import SwiftUI

struct WidgetToolbar: View {
    let colors: [Color] = [
        .skyBlue,
        .hotPink,
        .brightYellow,
        .limeGreen,
        .vibrantOrange
    ]

    var body: some View {
        HStack {
            ForEach(colors.indices, id: \.self) { index in
                colors[index]
                    .frame(width: 50, height: 50)
                    .clipShape(Capsule())
                
                // Add equal spacing between elements.
                if index < colors.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .appShadow()
    }
}

#Preview {
    WidgetToolbar()
}
