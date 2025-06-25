import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var page = 0
    
    var body: some View {
        ZStack {
            AnimatedWaterBackground()
            TabView(selection: $page) {
                OnboardingPage(
                    image: "drop.fill",
                    title: "Welcome to WaterCheck",
                    subtitle: "Stay healthy and hydrated every day with ease."
                )
                .tag(0)
                OnboardingPage(
                    image: "chart.bar.xaxis",
                    title: "Track Your Hydration",
                    subtitle: "Log your water intake, view stats, and build healthy habits."
                )
                .tag(1)
                OnboardingPage(
                    image: "target",
                    title: "Set Your Goal",
                    subtitle: "Personalize your daily water goal and get reminders."
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            VStack {
                Spacer()
                HStack {
                    if page < 2 {
                        Button("Skip") {
                            withAnimation { hasSeenOnboarding = true }
                        }
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.leading, 24)
                        Spacer()
                        Button("Next") {
                            withAnimation { page += 1 }
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                        )
                        .padding(.trailing, 24)
                    } else {
                        Button(action: { withAnimation { hasSeenOnboarding = true } }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Start Hydrating")
                            }
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 16)
                            .background(
                                Capsule().fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                            )
                        }
                        .padding(.bottom, 32)
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .ignoresSafeArea()
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.12)]), startPoint: .top, endPoint: .bottom))
                    .frame(width: 140, height: 140)
                    .shadow(color: .cyan.opacity(0.10), radius: 18, x: 0, y: 8)
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.blue)
            }
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
} 