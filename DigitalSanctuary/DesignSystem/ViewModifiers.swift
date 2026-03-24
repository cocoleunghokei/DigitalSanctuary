import SwiftUI

// MARK: - Sanctuary Card (no borders, depth via background)

struct SanctuaryCardModifier: ViewModifier {
    var background: Color
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Glassmorphic (frosted blur for nav bars)

struct GlassmorphicModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color.dsSurface
                    .opacity(0.85)
                    .background(.ultraThinMaterial)
            )
    }
}

// MARK: - Gradient Card (primary hero cards)

struct GradientCardModifier: ViewModifier {
    var gradient: LinearGradient
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - View extensions

extension View {
    func sanctuaryCard(
        background: Color = .dsSurfaceContainerLow,
        cornerRadius: CGFloat = 24
    ) -> some View {
        modifier(SanctuaryCardModifier(background: background, cornerRadius: cornerRadius))
    }

    func glassmorphic() -> some View {
        modifier(GlassmorphicModifier())
    }

    func gradientCard(
        gradient: LinearGradient = .dsPrimaryGradient,
        cornerRadius: CGFloat = 24
    ) -> some View {
        modifier(GradientCardModifier(gradient: gradient, cornerRadius: cornerRadius))
    }
}

// MARK: - Rounded corner helper (for top-only radius)

struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
