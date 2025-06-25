import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var hydrationManager: HydrationManager
    @State private var showingResetAlert = false
    @State private var showingPrivacyPolicy = false
    @State private var dailyGoal: Double = 2500
    @State private var showingGoalEditor = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedWaterBackground()
                
                ScrollView {
                    VStack(spacing: 25) {
                        dailyGoalSection
                        appSettingsSection
                        supportSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                dailyGoal = hydrationManager.dailyGoal
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your water intake data. This action cannot be undone.")
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingGoalEditor) {
                GoalEditorView(dailyGoal: $dailyGoal)
            }
        }
    }
    
    private var dailyGoalSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Daily Goal")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(dailyGoal))ml")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Daily water intake goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingGoalEditor = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("App Settings")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "trash.fill",
                    title: "Reset Data",
                    subtitle: "Clear all water intake data",
                    color: .red
                ) {
                    showingResetAlert = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Support")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Help us with a 5-star rating",
                    color: .yellow
                ) {
                    rateApp()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    color: .blue
                ) {
                    showingPrivacyPolicy = true
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "envelope.fill",
                    title: "Contact Us",
                    subtitle: "Send us feedback",
                    color: .purple
                ) {
                    contactUs()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func resetAllData() {
        hydrationManager.currentIntake = 0
        hydrationManager.todayEntries = []
        hydrationManager.historicalData = []
        hydrationManager.saveData()
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func contactUs() {
        if let url = URL(string: "mailto:support@watercheck.app") {
            UIApplication.shared.open(url)
        }
    }
    
    private func exportDataToCSV() {
        var csvString = "Date,Total Intake (ml),Entries,Goal Met\n"
        
        // Add today's data if any
        if hydrationManager.currentIntake > 0 {
            let today = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let todayString = formatter.string(from: today)
            csvString += "\(todayString),\(Int(hydrationManager.currentIntake)),\(hydrationManager.todayEntries.count),\(hydrationManager.currentIntake >= hydrationManager.dailyGoal)\n"
        }
        
        // Add historical data
        for data in hydrationManager.historicalData {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: data.date)
            csvString += "\(dateString),\(Int(data.totalIntake)),\(data.entries),\(data.goalMet)\n"
        }
        
        // Save to documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsPath.appendingPathComponent("watercheck_data.csv")
            
            do {
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                
                // Share the file
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.present(activityVC, animated: true)
                }
            } catch {
                print("Error saving CSV: \(error)")
            }
        }
    }
}

struct GoalEditorView: View {
    @Binding var dailyGoal: Double
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hydrationManager: HydrationManager
    @State private var tempGoal: Double = 2500
    
    private let goalOptions: [Double] = [1500, 2000, 2500, 3000, 3500, 4000]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.cyan.opacity(0.05)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "target")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Set Daily Goal")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Choose your daily water intake target")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recommended Goals")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(goalOptions, id: \.self) { goal in
                                Button(action: {
                                    tempGoal = goal
                                }) {
                                    VStack(spacing: 8) {
                                        Text("\(Int(goal))ml")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(tempGoal == goal ? .white : .blue)
                                        
                                        Text(goalDescription(for: goal))
                                            .font(.caption)
                                            .foregroundColor(tempGoal == goal ? .white.opacity(0.8) : .secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(height: 80)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(tempGoal == goal ? Color.blue : Color.blue.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Custom Goal")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Slider(value: $tempGoal, in: 1000...5000, step: 100)
                                .accentColor(.blue)
                            
                            Text("\(Int(tempGoal))ml")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(width: 80)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dailyGoal = tempGoal
                        hydrationManager.updateDailyGoal(tempGoal)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            
                            Text("Save Goal")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                tempGoal = dailyGoal
            }
        }
    }
    
    private func goalDescription(for goal: Double) -> String {
        switch goal {
        case 1500: return "Light Activity"
        case 2000: return "Moderate Activity"
        case 2500: return "Active Lifestyle"
        case 3000: return "Very Active"
        case 3500: return "Athlete"
        case 4000: return "High Performance"
        default: return "Custom Goal"
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Group {
                        Text("Data Collection")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("WaterCheck collects and stores your water intake data locally on your device. We do not collect, transmit, or share any personal information with third parties.")
                        
                        Text("Data Usage")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Your water intake data is used solely to provide you with hydration tracking features, progress visualization, and personalized insights.")
                        
                        Text("Data Storage")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("All data is stored locally on your device using iOS UserDefaults. You can reset all data at any time through the app settings.")
                        
                        Text("Third-Party Services")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("WaterCheck does not integrate with any third-party services or analytics platforms. Your data remains private and secure.")
                        
                        Text("Contact")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("If you have any questions about this privacy policy, please contact us at support@watercheck.app")
                    }
                    .font(.body)
                    .foregroundColor(.primary)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(HydrationManager())
} 