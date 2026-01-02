//
//  DesignSystem.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI

// MARK: - Design System Colors
struct DesignColors {
    // Purple gradient colors
    static let purpleLight = Color(red: 0.7, green: 0.5, blue: 0.9)
    static let purpleMedium = Color(red: 0.6, green: 0.4, blue: 0.8)
    static let purpleDark = Color(red: 0.5, green: 0.3, blue: 0.7)
    static let purpleAccent = Color(red: 0.8, green: 0.6, blue: 1.0)
    
    // Cycle phase colors - яркие и понятные
    static let periodColor = Color(red: 0.95, green: 0.2, blue: 0.3) // Ярко-красный для менструации
    static let ovulationColor = Color(red: 0.2, green: 0.85, blue: 0.4) // Ярко-зеленый для овуляции
    static let follicularColor = Color(red: 0.3, green: 0.5, blue: 0.95) // Ярко-синий для фолликулярной
    static let lutealColor = Color(red: 0.95, green: 0.65, blue: 0.2) // Ярко-оранжевый для лютеиновой
    
    // Background colors
    static func backgroundGradient(colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [purpleDark.opacity(0.8), purpleMedium.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [purpleLight.opacity(0.3), purpleMedium.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Glassmorphism Support Check
struct BlurSupport {
    static var isAvailable: Bool {
        // Check if blur effects are available
        if #available(iOS 13.0, *) {
            return !UIAccessibility.isReduceTransparencyEnabled
        }
        return false
    }
}

// MARK: - Glass Card View
struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if BlurSupport.isAvailable {
                // Glassmorphism style
                content
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.1)
                                    : Color.white.opacity(0.3)
                            )
                            .background(
                                Group {
                                    if #available(iOS 15.0, *) {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.ultraThinMaterial)
                                    } else if #available(iOS 13.0, *) {
                                        // For iOS 13-14, use a semi-transparent color instead of material
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                colorScheme == .dark
                                                    ? Color.black.opacity(0.3)
                                                    : Color.white.opacity(0.5)
                                            )
                                    }
                                }
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.2)
                                    : Color.white.opacity(0.5),
                                lineWidth: 1
                            )
                    )
            } else {
                // Flat fallback style
                content
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                colorScheme == .dark
                                    ? DesignColors.purpleDark.opacity(0.6)
                                    : DesignColors.purpleLight.opacity(0.4)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
            }
        }
    }
}

// MARK: - Neumorphic Button
struct NeumorphicButton: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.headline)
            .foregroundColor(colorScheme == .dark ? .white : DesignColors.purpleDark)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    if BlurSupport.isAvailable {
                        // Neumorphic style
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                colorScheme == .dark
                                    ? DesignColors.purpleMedium.opacity(0.3)
                                    : DesignColors.purpleLight.opacity(0.2)
                            )
                            .shadow(color: Color.white.opacity(0.1), radius: 5, x: -3, y: -3)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 3, y: 3)
                    } else {
                        // Flat style
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                colorScheme == .dark
                                    ? DesignColors.purpleMedium
                                    : DesignColors.purpleLight
                            )
                    }
                }
            )
        }
    }
}

// MARK: - Intensity Indicator
struct IntensityIndicator: View {
    let intensity: Int
    let maxIntensity: Int = 5
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxIntensity, id: \.self) { index in
                Circle()
                    .fill(index <= intensity ? DesignColors.periodColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Symptom Rating View
struct SymptomRatingView: View {
    let title: String
    let icon: String
    @Binding var rating: Int
    let maxRating: Int = 5
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(DesignColors.purpleMedium)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(1...maxRating, id: \.self) { index in
                    Button(action: {
                        rating = index
                    }) {
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .foregroundColor(
                                index <= rating 
                                    ? DesignColors.purpleAccent 
                                    : Color.gray.opacity(0.3)
                            )
                            .font(.system(size: 20, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

// MARK: - Phase Badge
struct PhaseBadge: View {
    let phase: CyclePhase
    let size: CGFloat = 12
    
    var body: some View {
        Circle()
            .fill(phase.color)
            .frame(width: size, height: size)
    }
}

// MARK: - Cycle Phase
enum CyclePhase {
    case period
    case follicular
    case ovulation
    case luteal
    
    var color: Color {
        switch self {
        case .period: return DesignColors.periodColor
        case .follicular: return DesignColors.follicularColor
        case .ovulation: return DesignColors.ovulationColor
        case .luteal: return DesignColors.lutealColor
        }
    }
    
    var name: String {
        switch self {
        case .period: return "menstruation".localized
        case .follicular: return "follicular_phase".localized
        case .ovulation: return "ovulation_phase".localized
        case .luteal: return "luteal_phase".localized
        }
    }
}

