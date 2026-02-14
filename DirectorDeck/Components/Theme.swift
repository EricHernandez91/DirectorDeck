import SwiftUI

enum DDTheme {
    static let accent = Color("AccentColor")
    static let teal = Color(red: 0, green: 0.737, blue: 0.831)
    
    // Dark navy palette (not pure black)
    static let deepBackground = Color(hex: "#0D0D14")
    static let surfaceBackground = Color(hex: "#111118")
    static let cardStart = Color(hex: "#151520")
    static let cardEnd = Color(hex: "#1C1C28")
    static let cardBorder = Color.white.opacity(0.06)
    
    // Accent colors
    static let green = Color(hex: "#4CD964")
    
    static let cardCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
    static let standardPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 28
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [deepBackground, surfaceBackground],
            startPoint: .top,
            endPoint: .bottom
        )
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
                    .stroke(DDTheme.cardBorder, lineWidth: 1)
            )
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

struct SectionLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(.secondary.opacity(0.6))
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
