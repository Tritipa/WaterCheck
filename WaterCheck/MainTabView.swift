import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var hydrationManager: HydrationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "drop.fill")
                    Text("Today")
                }
                .tag(0)
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("History")
                }
                .tag(1)
            BMICalculatorView()
                .tabItem {
                    Image(systemName: "figure.stand")
                    Text("BMI & Water")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView().environmentObject(HydrationManager())
} 