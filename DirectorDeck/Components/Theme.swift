import SwiftUI

enum DDTheme {
    static let accent = Color("AccentColor")
    static let teal = Color(red: 0, green: 0.737, blue: 0.831)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let subtleBackground = Color(.systemGroupedBackground)
    
    static let deepBackground = Color(red: 0.039, green: 0.039, blue: 0.059)
    static let surfaceBackground = Color(red: 0.067, green: 0.067, blue: 0.094)
    
    static let cardCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
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

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }
    
    func sectionHeader() -> some View {
        self
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(1.2)
    }
}

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
