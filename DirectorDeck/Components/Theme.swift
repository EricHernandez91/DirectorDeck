import SwiftUI

enum DDTheme {
    static let accent = Color("AccentColor")
    static let teal = Color(hex: "#00BCD4")
    
    // Color system
    static let amber = Color(hex: "#F5A623")
    static let success = Color(hex: "#4CAF50")
    static let mutedBlueGray = Color(hex: "#7B8FA1")
    
    // Purple/violet secondary accent
    static let violet = Color(hex: "#8B5CF6")
    static let violetGlow = Color(hex: "#7C3AED")
    
    // Dark navy palette (not pure black)
    static let deepBackground = Color(hex: "#08091A")
    static let surfaceBackground = Color(hex: "#0D0E1E")
    static let cardStart = Color(hex: "#12132A")
    static let cardEnd = Color(hex: "#1A1B35")
    static let cardBorder = Color(hex: "#8B5CF6").opacity(0.08)
    static let pillBackground = Color(hex: "#16172A")
    
    // Accent colors
    static let green = Color(hex: "#4CAF50")
    
    static let cardCornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let standardPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 28
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [deepBackground, surfaceBackground, deepBackground],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var ambientGlow: RadialGradient {
        RadialGradient(colors: [violet.opacity(0.03), .clear], center: .top, startRadius: 0, endRadius: 400)
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardStart, cardEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
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

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Card Modifiers

struct DashboardCardModifier: ViewModifier {
    var cornerRadius: CGFloat = DDTheme.cardCornerRadius
    
    func body(content: Content) -> some View {
        content
            .background(DDTheme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
            )
            .shadow(color: Color(hex: "#8B5CF6").opacity(0.08), radius: 20, y: 4)
            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }
}

struct GlowingCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DDTheme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [DDTheme.violet.opacity(0.2), DDTheme.teal.opacity(0.1), DDTheme.violet.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: DDTheme.violet.opacity(0.1), radius: 24, y: 4)
            .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
    }
}

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = DDTheme.cardCornerRadius
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .modifier(DashboardCardModifier(cornerRadius: cornerRadius))
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
                .background(DDTheme.cardGradient, in: Capsule())
                .overlay(Capsule().stroke(DDTheme.cardBorder, lineWidth: 1))
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
                .background(DDTheme.cardGradient, in: Circle())
                .overlay(Circle().stroke(DDTheme.cardBorder, lineWidth: 1))
        }
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.modifier(DashboardCardModifier())
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
    
    func dashboardCard(cornerRadius: CGFloat = DDTheme.cardCornerRadius) -> some View {
        modifier(DashboardCardModifier(cornerRadius: cornerRadius))
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
    
    func glowingCard() -> some View {
        modifier(GlowingCardModifier())
    }
}

// MARK: - Pill View

struct PillView: View {
    let text: String
    var color: Color = .white.opacity(0.7)
    var background: Color = DDTheme.pillBackground
    
    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(background, in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.04), lineWidth: 0.5))
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
                .font(.system(.title3, weight: .semibold))
            Spacer()
        }
    }
}

struct SectionLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.4))
            .tracking(1.5)
            .textCase(.uppercase)
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
