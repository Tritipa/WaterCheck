import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var hydrationManager: HydrationManager
    @State private var selectedTimeframe: Timeframe = .week
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedWaterBackground()
                LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.12), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                Color.white.opacity(0.01).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        timeframeSelector
                        chartView
                        statisticsView
                        recentDaysView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 36)
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeframeSelector: some View {
        HStack(spacing: 0) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeframe = timeframe
                    }
                }) {
                    Text(timeframe.rawValue)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            Group {
                                if selectedTimeframe == timeframe {
                                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing)
                                } else {
                                    Color(.systemBackground).opacity(0.7)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.5))
                .shadow(color: Color.cyan.opacity(0.10), radius: 6, x: 0, y: 2)
        )
    }
    
    private var chartView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Water Intake Trend")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            let chartData = hydrationManager.getDataForTimeframe(selectedTimeframe)
            if chartData.isEmpty {
                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.12)]), startPoint: .top, endPoint: .bottom))
                            .frame(width: 110, height: 110)
                            .shadow(color: .cyan.opacity(0.10), radius: 16, x: 0, y: 8)
                        Image(systemName: "chart.bar.xaxis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 54, height: 54)
                            .foregroundColor(.blue.opacity(0.7))
                            .opacity(0.85)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: chartData.isEmpty)
                    }
                    Text("No water data yet")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("Start tracking your hydration and your stats will appear here.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                Chart {
                    ForEach(chartData) { dataPoint in
                        BarMark(
                            x: .value("Date", dataPoint.date, unit: .day),
                            y: .value("Intake", dataPoint.totalIntake)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .cyan]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            Text("\(value.as(Double.self)?.formatted(.number) ?? "")ml")
                                .font(.caption)
                        }
                    }
                }
                .chartXAxis {
                    if selectedTimeframe == .week {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.weekday(.abbreviated))
                                        .font(.caption2)
                                }
                            }
                        }
                    } else if selectedTimeframe == .month {
                        AxisMarks(values: .stride(by: .day, count: 7)) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.day().month(.abbreviated))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                }
                            }
                        }
                    } else if selectedTimeframe == .year {
                        AxisMarks(values: .stride(by: .month)) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.month(.abbreviated))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.10), radius: 12, x: 0, y: 6)
        )
    }
    
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Statistics")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            let stats = hydrationManager.getStatistics(for: selectedTimeframe)
            HStack(spacing: 18) {
                StatisticCard(title: "Average", value: "\(Int(stats.averageIntake))ml", icon: "chart.line.uptrend.xyaxis", color: .green)
                StatisticCard(title: "Best Day", value: "\(Int(stats.bestDayIntake))ml", icon: "star.fill", color: .orange)
                StatisticCard(title: "Goal Met", value: "\(stats.goalMetDays) days", icon: "checkmark.circle.fill", color: .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.10), radius: 12, x: 0, y: 6)
        )
    }
    
    private var recentDaysView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Recent Days")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            let recentData = hydrationManager.getDataForTimeframe(.week)
            if recentData.isEmpty {
                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.12)]), startPoint: .top, endPoint: .bottom))
                            .frame(width: 110, height: 110)
                            .shadow(color: .cyan.opacity(0.10), radius: 16, x: 0, y: 8)
                        Image(systemName: "drop.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 54, height: 54)
                            .foregroundColor(.blue.opacity(0.7))
                            .rotationEffect(.degrees(-18))
                            .opacity(0.85)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: recentData.isEmpty)
                    }
                    Text("No water data yet")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("Start tracking your hydration and your stats will appear here.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                ForEach(recentData, id: \.date) { data in
                    HStack(spacing: 16) {
                        Image(systemName: data.goalMet ? "checkmark.seal.fill" : "drop.fill")
                            .foregroundColor(data.goalMet ? .green : .blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.dateString)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("Intake: \(Int(data.totalIntake)) ml")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if data.goalMet {
                            Text("Goal met")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 8)
                    if data.date != recentData.last?.date {
                        Divider().background(Color.cyan.opacity(0.08))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.10), radius: 12, x: 0, y: 6)
        )
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.18), radius: 4, x: 0, y: 2)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    HistoryView()
        .environmentObject(HydrationManager())
} 