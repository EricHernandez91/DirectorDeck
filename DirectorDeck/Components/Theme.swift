import SwiftUI

enum DDTheme {
    static let accent = Color("AccentColor")
    static let teal = Color(red: 0, green: 0.737, blue: 0.831)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let subtleBackground = Color(.systemGroupedBackground)
    
    static let deepBackground = Color(red: 0.039, green: 0.039, blue: 0.059)
    static let surfaceBackground = Color(red: 0.067, green: 0.067, blue: 0.094)
    
    static let cardCornerRadius: CGFloat = 20
    static let smallCornerRadius: CGFloat = 12
    static let standardPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [deepBackground, surfaceBackground],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var tealGradient: LinearGradient {
        LinearGradient(
            colors: [teal, teal.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Liquid Glass Modifiers

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = DDTheme.cardCornerRadius
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        }
    }
}

struct LiquidGlassPillModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .capsule)
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
}

struct LiquidGlassCircleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .circle)
        } else {
            content
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.modifier(LiquidGlassModifier(cornerRadius: DDTheme.cardCornerRadius))
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.modifier(LiquidGlassModifier(cornerRadius: DDTheme.cardCornerRadius))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }
    
    func liquidGlass(cornerRadius: CGFloat = DDTheme.cardCornerRadius) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
    
    func liquidGlassPill() -> some View {
        modifier(LiquidGlassPillModifier())
    }
    
    func liquidGlassCircle() -> some View {
        modifier(LiquidGlassCircleModifier())
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)?
    var actionLabel: String = "Create"
    
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
                .foregroundStyle(DDTheme.teal)
        } description: {
            Text(subtitle)
        } actions: {
            if let action {
                Button(action: action) {
                    Text(actionLabel)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(DDTheme.teal)
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(DDTheme.teal)
                .font(.title3)
            Text(title)
                .font(.system(.title3, design: .rounded, weight: .semibold))
            Spacer()
        }
    }
}
