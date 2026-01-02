//
//  BlogView.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import SwiftUI

struct BlogView: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State private var selectedArticle: BlogArticle?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignColors.backgroundGradient(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(BlogArticle.allArticles) { article in
                            BlogArticleCard(article: article) {
                                selectedArticle = article
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("blog".localized)
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedArticle) { article in
                BlogArticleDetailView(article: article)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Blog Article Card
struct BlogArticleCard: View {
    let article: BlogArticle
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        // Category badge with gradient
                        Text(article.category.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [DesignColors.purpleMedium, DesignColors.purpleDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        if let readTime = article.readTime {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.caption2)
                                    .foregroundColor(DesignColors.purpleMedium)
                                Text("\(readTime) min")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignColors.purpleMedium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(DesignColors.purpleMedium.opacity(0.15))
                            )
                        }
                    }
                    
                    // Title with accent line
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Accent line
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignColors.purpleLight, DesignColors.purpleMedium],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 3)
                            .cornerRadius(1.5)
                    }
                    
                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Read more button with gradient
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Text("read_more".localized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [DesignColors.purpleMedium, DesignColors.purpleDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: DesignColors.purpleMedium.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Blog Article Detail View
struct BlogArticleDetailView: View {
    let article: BlogArticle
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var contentPadding: CGFloat {
        isIPad ? 60 : 16
    }
    
    private var contentMaxWidth: CGFloat {
        isIPad ? 800 : .infinity
    }
    
    private var headerPadding: CGFloat {
        isIPad ? 40 : 20
    }
    
    private var titleFontSize: CGFloat {
        isIPad ? 34 : 28
    }
    
    private var bodyFontSize: CGFloat {
        isIPad ? 19 : 17
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignColors.backgroundGradient(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header section with gradient background
                        VStack(alignment: .leading, spacing: isIPad ? 20 : 16) {
                            // Category and read time
                            HStack {
                                Text(article.category.uppercased())
                                    .font(.system(size: isIPad ? 13 : 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, isIPad ? 16 : 12)
                                    .padding(.vertical, isIPad ? 8 : 6)
                                    .background(
                                        LinearGradient(
                                            colors: [DesignColors.purpleMedium, DesignColors.purpleDark],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                if let readTime = article.readTime {
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: isIPad ? 13 : 11))
                                        Text("\(readTime) min read")
                                            .font(.system(size: isIPad ? 13 : 11, weight: .medium))
                                    }
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, isIPad ? 14 : 10)
                                    .padding(.vertical, isIPad ? 8 : 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.2))
                                    )
                                }
                            }
                            
                            // Title with gradient accent
                            VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
                                Text(article.title)
                                    .font(.system(size: titleFontSize, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // Accent line
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [DesignColors.purpleLight, DesignColors.purpleAccent],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: isIPad ? 5 : 4)
                                    .cornerRadius(2.5)
                            }
                        }
                        .padding(headerPadding)
                        .background(
                            LinearGradient(
                                colors: [DesignColors.purpleDark, DesignColors.purpleMedium],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(isIPad ? 24 : 20, corners: [.bottomLeft, .bottomRight])
                        
                        // Content section - centered on iPad
                        HStack {
                            if isIPad {
                                Spacer()
                            }
                            VStack(alignment: .leading, spacing: isIPad ? 28 : 20) {
                                ForEach(Array(article.content.enumerated()), id: \.offset) { index, paragraph in
                                    VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
                                        // Add accent dot for first paragraph
                                        if index == 0 {
                                            HStack(alignment: .top, spacing: isIPad ? 12 : 8) {
                                                Circle()
                                                    .fill(DesignColors.purpleMedium)
                                                    .frame(width: isIPad ? 10 : 8, height: isIPad ? 10 : 8)
                                                    .padding(.top, isIPad ? 8 : 6)
                                                Text(paragraph)
                                                    .font(.system(size: bodyFontSize))
                                                    .foregroundColor(.primary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .lineSpacing(isIPad ? 8 : 6)
                                            }
                                        } else {
                                            Text(paragraph)
                                                .font(.system(size: bodyFontSize))
                                                .foregroundColor(.primary)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineSpacing(isIPad ? 8 : 6)
                                        }
                                        
                                        // Add subtle divider between paragraphs
                                        if index < article.content.count - 1 {
                                            Divider()
                                                .background(DesignColors.purpleMedium.opacity(0.2))
                                                .padding(.vertical, isIPad ? 12 : 8)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: contentMaxWidth)
                            .padding(isIPad ? 40 : 20)
                            .background(
                                GlassCard {
                                    Color.clear
                                }
                            )
                            if isIPad {
                                Spacer()
                            }
                        }
                        .padding(.horizontal, contentPadding)
                        .padding(.top, isIPad ? 24 : 16)
                        .padding(.bottom, isIPad ? 48 : 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: isIPad ? 26 : 20))
                    .foregroundColor(.white)
            })
            .background(
                // Custom navigation bar background for iOS 14 compatibility
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [DesignColors.purpleDark, DesignColors.purpleMedium],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: geometry.safeAreaInsets.top + 44)
                    .ignoresSafeArea(edges: .top)
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Helper extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
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

// MARK: - Blog Article Model
struct BlogArticle: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let category: String
    let readTime: Int?
    let content: [String]
    
    static let allArticles: [BlogArticle] = [
        BlogArticle(
            title: "Understanding Your Menstrual Cycle: A Complete Guide",
            summary: "Learn about the four phases of your menstrual cycle and how to track them effectively for better health awareness.",
            category: "Education",
            readTime: 5,
            content: [
                "Your menstrual cycle is a natural process that occurs in your body every month. Understanding how it works can help you better track your periods, predict ovulation, and maintain optimal reproductive health.",
                
                "The menstrual cycle consists of four main phases:",
                
                "1. Menstrual Phase (Days 1-5): This is when you experience your period. The lining of your uterus sheds, and you may experience bleeding for 3-7 days. Hormone levels (estrogen and progesterone) are at their lowest during this phase.",
                
                "2. Follicular Phase (Days 1-13): This phase begins on the first day of your period and continues until ovulation. Your body prepares for ovulation by developing follicles in your ovaries. Estrogen levels gradually increase, preparing the uterine lining for a potential pregnancy.",
                
                "3. Ovulation (Day 14, approximately): This is when a mature egg is released from your ovary. Ovulation typically occurs around day 14 of a 28-day cycle, but can vary. This is your most fertile period, and you may notice increased cervical mucus and a slight rise in basal body temperature.",
                
                "4. Luteal Phase (Days 15-28): After ovulation, your body produces progesterone to maintain the uterine lining. If pregnancy doesn't occur, hormone levels drop, and the cycle begins again with menstruation.",
                
                "Tracking your cycle helps you understand your body's patterns, predict your next period, and identify any irregularities that may need medical attention."
            ]
        ),
        BlogArticle(
            title: "How to Track Your Period Accurately",
            summary: "Discover the best practices for tracking your menstrual cycle, including what to record and how to identify patterns.",
            category: "Tips",
            readTime: 4,
            content: [
                "Accurate period tracking is essential for understanding your menstrual cycle and maintaining reproductive health. Here are some best practices:",
                
                "What to Track:",
                "• Start and end dates of your period",
                "• Flow intensity (light, medium, heavy)",
                "• Symptoms like cramps, bloating, mood changes",
                "• Energy levels throughout your cycle",
                "• Any unusual symptoms or changes",
                
                "Why It Matters:",
                "Tracking helps you predict your next period, identify your fertile window, and notice any irregularities. Consistent tracking over several months provides valuable insights into your cycle patterns.",
                
                "Tips for Accurate Tracking:",
                "1. Mark the first day of bleeding as day 1 of your cycle",
                "2. Track consistently every day, not just during your period",
                "3. Note any symptoms, even if they seem minor",
                "4. Review your data monthly to identify patterns",
                "5. Use a reliable tracking app like Periodly for convenience",
                
                "Remember, every woman's cycle is unique. What's normal for you may differ from others, so focus on understanding your own patterns."
            ]
        ),
        BlogArticle(
            title: "Common Menstrual Cycle Irregularities and When to See a Doctor",
            summary: "Learn about normal cycle variations versus potential health concerns that require medical attention.",
            category: "Health",
            readTime: 6,
            content: [
                "While menstrual cycles can vary, certain irregularities may indicate underlying health issues. Understanding what's normal and what requires medical attention is important for your reproductive health.",
                
                "Normal Variations:",
                "• Cycle length between 21-35 days is considered normal",
                "• Period duration of 2-7 days is typical",
                "• Some variation in cycle length month-to-month is normal",
                "• Light to moderate cramping is common",
                
                "When to Consult a Healthcare Provider:",
                "• Cycles shorter than 21 days or longer than 35 days consistently",
                "• Periods lasting more than 7 days",
                "• Missing periods for 3+ months (if not pregnant)",
                "• Extremely heavy bleeding (soaking through a pad/tampon every hour)",
                "• Severe pain that interferes with daily activities",
                "• Sudden changes in your cycle pattern",
                "• Bleeding between periods",
                "• Symptoms of anemia (fatigue, dizziness, pale skin)",
                
                "Common Causes of Irregularities:",
                "• Stress and lifestyle factors",
                "• Hormonal imbalances",
                "• Polycystic ovary syndrome (PCOS)",
                "• Thyroid disorders",
                "• Weight changes",
                "• Certain medications",
                
                "Important: This information is for educational purposes only. Always consult with a healthcare professional for medical advice and diagnosis."
            ]
        ),
        BlogArticle(
            title: "Fertility Awareness: Understanding Your Fertile Window",
            summary: "Learn how to identify your most fertile days and understand the connection between your cycle and fertility.",
            category: "Fertility",
            readTime: 5,
            content: [
                "Understanding your fertile window is important whether you're trying to conceive or want to better understand your reproductive health.",
                
                "What is the Fertile Window?",
                "The fertile window is the time during your cycle when you're most likely to become pregnant. This typically includes the 5 days before ovulation and the day of ovulation itself.",
                
                "How to Identify Your Fertile Window:",
                "1. Track your cycle length over several months",
                "2. Ovulation usually occurs 14 days before your next period",
                "3. Your fertile window is approximately 5-6 days before ovulation",
                "4. Look for signs like increased cervical mucus and slight temperature changes",
                
                "Signs of Ovulation:",
                "• Increased, clear, stretchy cervical mucus (like egg whites)",
                "• Slight rise in basal body temperature",
                "• Mild cramping or twinging on one side (mittelschmerz)",
                "• Increased libido",
                "• Positive ovulation predictor test",
                
                "Important Considerations:",
                "• Sperm can survive in the female reproductive tract for up to 5 days",
                "• The egg is viable for about 12-24 hours after ovulation",
                "• Cycle tracking is not 100% reliable for contraception",
                "• For pregnancy planning, consult with a fertility specialist",
                
                "Remember: Periodly is a tracking tool only. For fertility planning or contraception, always consult with healthcare professionals."
            ]
        ),
        BlogArticle(
            title: "Managing PMS Symptoms Naturally",
            summary: "Discover natural ways to alleviate premenstrual syndrome symptoms and improve your overall well-being during your cycle.",
            category: "Wellness",
            readTime: 4,
            content: [
                "Premenstrual Syndrome (PMS) affects many women in the days leading up to their period. While symptoms vary, there are natural ways to manage them effectively.",
                
                "Common PMS Symptoms:",
                "• Mood swings and irritability",
                "• Bloating and water retention",
                "• Fatigue and low energy",
                "• Cramps and discomfort",
                "• Food cravings",
                "• Sleep disturbances",
                
                "Natural Management Strategies:",
                "1. Regular Exercise: Moderate physical activity can reduce cramps and improve mood",
                "2. Balanced Diet: Eat regular meals with complex carbs, protein, and healthy fats",
                "3. Stay Hydrated: Drink plenty of water to reduce bloating",
                "4. Limit Salt and Caffeine: These can worsen bloating and mood swings",
                "5. Get Enough Sleep: Aim for 7-9 hours of quality sleep",
                "6. Stress Management: Practice relaxation techniques like meditation or yoga",
                "7. Supplements: Consider magnesium, vitamin B6, or omega-3 fatty acids (consult your doctor first)",
                
                "When to Seek Help:",
                "If PMS symptoms significantly interfere with your daily life, consider speaking with a healthcare provider. They can help determine if you have Premenstrual Dysphoric Disorder (PMDD) or other conditions that may require treatment.",
                
                "Tracking your symptoms in Periodly can help you identify patterns and prepare for your cycle each month."
            ]
        ),
        BlogArticle(
            title: "The Science Behind Period Tracking Apps",
            summary: "Learn how period tracking apps work, their benefits, and important considerations for using them effectively.",
            category: "Technology",
            readTime: 3,
            content: [
                "Period tracking apps like Periodly use algorithms and data analysis to help you understand your menstrual cycle better.",
                
                "How They Work:",
                "Period tracking apps analyze your input data (period dates, cycle length, symptoms) to:",
                "• Calculate average cycle length",
                "• Predict your next period",
                "• Estimate ovulation dates",
                "• Identify patterns in your cycle",
                
                "Benefits of Using a Tracking App:",
                "• Convenience: Easy to record and access your cycle data",
                "• Pattern Recognition: Apps can identify trends you might miss",
                "• Reminders: Never forget to track or prepare for your period",
                "• Data Visualization: See your cycle history at a glance",
                "• Privacy: Apps like Periodly store data locally on your device",
                
                "Important Considerations:",
                "• Apps provide estimates, not medical diagnoses",
                "• Always consult healthcare professionals for medical concerns",
                "• No app can guarantee 100% accurate predictions",
                "• Your cycle can vary, and apps adapt to your patterns over time",
                
                "Periodly is designed to be a helpful tool for tracking and understanding your cycle, but it should complement, not replace, professional medical advice."
            ]
        )
    ]
}

