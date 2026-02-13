import SwiftUI

enum DDTheme {
    static let accent = Color("AccentColor")
    static let teal = Color(red: 0, green: 0.737, blue: 0.831)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let subtleBackground = Color(.systemGroupedBackground)
    
    static let cardCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
    static let standardPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DDTheme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func glassCard() -> some View {
        modifier(GlassCardStyle())
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
                .font(.title3.weight(.semibold))
            Spacer()
        }
    }
}
