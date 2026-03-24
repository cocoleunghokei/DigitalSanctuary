import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension Color {
    static let dsPrimary                 = Color(hex: "24667f")
    static let dsPrimaryContainer        = Color(hex: "a3e0fc")
    static let dsPrimaryDim              = Color(hex: "125a72")
    static let dsSecondaryContainer      = Color(hex: "c0edd0")
    static let dsTertiaryContainer       = Color(hex: "fee57a")
    static let dsSurface                 = Color(hex: "f8f9fa")
    static let dsSurfaceContainerLow     = Color(hex: "f1f4f5")
    static let dsSurfaceContainerLowest  = Color(hex: "ffffff")
    static let dsSurfaceContainerHigh    = Color(hex: "e5e9eb")
    static let dsSurfaceContainerHighest = Color(hex: "dee3e6")
    static let dsOnSurface               = Color(hex: "2d3335")
    static let dsOnSurfaceVariant        = Color(hex: "5a6062")
    static let dsOnPrimaryFixed          = Color(hex: "003d50")
}

extension LinearGradient {
    static let dsPrimaryGradient = LinearGradient(
        colors: [.dsPrimary, .dsPrimaryContainer],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let dsMoodCloudGradient = LinearGradient(
        colors: [.dsSecondaryContainer, .dsPrimaryContainer],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
