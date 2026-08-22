import SwiftUI

struct WidgetInstance: Identifiable {
    let id: UUID = UUID()
    var color: Color
    var isPreview: Bool = false
    var frame: CGRect = .zero    
}
