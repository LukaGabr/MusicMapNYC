import SwiftUI

// Visual identity: vinyl-record palette. Built up in small steps —
// this first pass only defines colors and fonts. Badges, chips, and
// other components get added once the base palette is confirmed.
enum Theme {
    // MARK: Colors
    static let background = Color(red: 0.11, green: 0.10, blue: 0.09)   // #1C1917
    static let surface = Color(red: 0.16, green: 0.14, blue: 0.13)      // #2A2521
    static let paper = Color(red: 0.95, green: 0.93, blue: 0.89)        // #F2EDE4
    static let paperMuted = paper.opacity(0.6)

    static let marigold = Color(red: 0.85, green: 0.64, blue: 0.25)     // #D9A441

    // MARK: Fonts
    // "New York" is Apple's built-in serif — no font file to bundle.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
