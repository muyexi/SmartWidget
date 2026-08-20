import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()

            VStack {
                WidgetWelcomeView()
            }
            .aspectRatio(1.0, contentMode: .fit)

            Spacer()
            WidgetToolbar()
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview {
    ContentView()
}
