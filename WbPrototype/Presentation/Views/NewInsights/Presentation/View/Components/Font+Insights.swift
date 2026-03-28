import SwiftUI

extension Font {
    /// Figtree font helper for the Insights tab.
    static func figtree(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold:         name = "Figtree-Bold"
        case .semibold:     name = "Figtree-SemiBold"
        case .medium:       name = "Figtree-Medium"
        case .heavy,
             .black:        name = "Figtree-ExtraBold"
        default:            name = "Figtree-Regular"
        }
        return .custom(name, size: size)
    }
}
