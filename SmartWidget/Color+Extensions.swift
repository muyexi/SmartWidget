import SwiftUI

extension Color {
    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    // MARK: - App Palette
    static let gray = Color(hex: "#808080")
    static let skyBlue = Color(hex: "#00CFFF")
    static let hotPink = Color(hex: "#FF5C93")
    static let brightYellow = Color(hex: "#FFEB3B")
    static let limeGreen = Color(hex: "#AEEA00")
    static let vibrantOrange = Color(hex: "#FF6D00")
}
