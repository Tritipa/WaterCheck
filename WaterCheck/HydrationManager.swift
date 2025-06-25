import Foundation
import SwiftUI

class HydrationManager: ObservableObject {
    @Published var currentIntake: Double = 0
    @Published var dailyGoal: Double = 2500
    @Published var todayEntries: [WaterEntry] = []
    @Published var historicalData: [DailyData] = []
    @Published var streak: Int = 0
    @Published var bestDay: Double = 0
    @Published var yesterdayIntake: Double = 0
    @Published var achievementMessage: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let currentDateKey = "currentDate"
    private let intakeKey = "currentIntake"
    private let entriesKey = "todayEntries"
    private let goalKey = "dailyGoal"
    private let historicalKey = "historicalData"
    
    private let waterQuotes = [
        "Water is life's matter and matrix. — Albert Szent-Gyorgyi",
        "Thousands have lived without love, not one without water. — W. H. Auden",
        "Drink more water. Your skin, your hair, your mind, and your body will thank you.",
        "Pure water is the world's first and foremost medicine. — Slovak Proverb",
        "When you drink water, remember the spring. — Chinese Proverb",
        "Hydrate to feel great!",
        "You're not sick, you're thirsty. — F. Batmanghelidj",
        "A glass of water a day keeps fatigue away.",
        "Stay hydrated, stay healthy!"
    ]
    
    init() {
        loadData()
        checkDateReset()
    }
    
    var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(currentIntake / dailyGoal, 1.0)
    }
    
    var progressMessage: String {
        if currentIntake >= dailyGoal {
            return "Excellent! You've reached your goal! 🎉"
        } else if currentIntake >= dailyGoal * 0.8 {
            return "Almost there! Keep going! 💪"
        } else if currentIntake >= dailyGoal * 0.5 {
            return "Great progress! You're halfway there! 🌊"
        } else {
            return "Stay hydrated! Every drop counts! 💧"
        }
    }
    
    func addWater(amount: Double) {
        currentIntake += amount
        let entry = WaterEntry(amount: amount, timestamp: Date())
        todayEntries.insert(entry, at: 0)
        saveData()
        updateAchievements()
    }
    
    func removeEntry(_ entry: WaterEntry) {
        if let index = todayEntries.firstIndex(where: { $0.id == entry.id }) {
            currentIntake -= entry.amount
            todayEntries.remove(at: index)
            saveData()
        }
    }
    
    func updateDailyGoal(_ newGoal: Double) {
        dailyGoal = newGoal
        saveData()
        updateAchievements()
    }
    
    func saveData() {
        userDefaults.set(Date(), forKey: currentDateKey)
        userDefaults.set(currentIntake, forKey: intakeKey)
        userDefaults.set(dailyGoal, forKey: goalKey)
        
        if let encoded = try? JSONEncoder().encode(todayEntries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
        
        if let encoded = try? JSONEncoder().encode(historicalData) {
            userDefaults.set(encoded, forKey: historicalKey)
        }
        
        updateAchievements()
    }
    
    private func checkDateReset() {
        let today = Calendar.current.startOfDay(for: Date())
        let savedDate = userDefaults.object(forKey: currentDateKey) as? Date ?? Date.distantPast
        
        if !Calendar.current.isDate(today, inSameDayAs: savedDate) {
            // Save yesterday's data to history before resetting
            if currentIntake > 0 {
                let yesterdayData = DailyData(
                    date: savedDate,
                    totalIntake: currentIntake,
                    entries: todayEntries.count,
                    goalMet: currentIntake >= dailyGoal
                )
                historicalData.insert(yesterdayData, at: 0)
                saveData()
            }
            resetDailyData()
        }
    }
    
    private func resetDailyData() {
        currentIntake = 0
        todayEntries = []
        saveData()
    }
    
    private func loadData() {
        currentIntake = userDefaults.double(forKey: intakeKey)
        dailyGoal = userDefaults.double(forKey: goalKey)
        
        if dailyGoal == 0 {
            dailyGoal = 2500 // Default goal
        }
        
        if let data = userDefaults.data(forKey: entriesKey),
           let entries = try? JSONDecoder().decode([WaterEntry].self, from: data) {
            todayEntries = entries
        }
        
        if let data = userDefaults.data(forKey: historicalKey),
           let history = try? JSONDecoder().decode([DailyData].self, from: data) {
            historicalData = history
        }
        
        updateAchievements()
    }
    
    // Get data for specific timeframe
    func getDataForTimeframe(_ timeframe: Timeframe) -> [DailyData] {
        let calendar = Calendar.current
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        
        let daysToInclude: Int
        switch timeframe {
        case .week:
            daysToInclude = 7
        case .month:
            daysToInclude = 30
        case .year:
            daysToInclude = 365
        }
        
        let cutoffDate = calendar.date(byAdding: .day, value: -daysToInclude, to: startOfToday) ?? startOfToday
        
        var result = historicalData.filter { $0.date >= cutoffDate }

        if currentIntake > 0 {
            let todayData = DailyData(
                date: startOfToday,
                totalIntake: currentIntake,
                entries: todayEntries.count,
                goalMet: currentIntake >= dailyGoal
            )
            result.insert(todayData, at: 0)
        }

        return result
    }
    
    // Get statistics for timeframe
    func getStatistics(for timeframe: Timeframe) -> Statistics {
        let data = getDataForTimeframe(timeframe)
        
        guard !data.isEmpty else {
            return Statistics(averageIntake: 0, bestDayIntake: 0, goalMetDays: 0, totalDays: 0)
        }
        
        let totalIntake = data.reduce(0) { $0 + $1.totalIntake }
        let averageIntake = totalIntake / Double(data.count)
        let bestDayIntake = data.map(\.totalIntake).max() ?? 0
        let goalMetDays = data.filter(\.goalMet).count
        
        return Statistics(
            averageIntake: averageIntake,
            bestDayIntake: bestDayIntake,
            goalMetDays: goalMetDays,
            totalDays: data.count
        )
    }
    
    func randomQuote() -> String {
        waterQuotes.randomElement() ?? "Stay hydrated!"
    }
    
    func updateAchievements() {
        let calendar = Calendar.current
        var streakCount = 0
        var prevDate: Date? = nil
        for day in historicalData.sorted(by: { $0.date > $1.date }) {
            if day.goalMet {
                if let prev = prevDate {
                    if calendar.date(byAdding: .day, value: -1, to: prev)! == calendar.startOfDay(for: day.date) {
                        streakCount += 1
                    } else {
                        break
                    }
                } else {
                    streakCount = 1
                }
                prevDate = calendar.startOfDay(for: day.date)
            } else {
                break
            }
        }
        streak = streakCount
        bestDay = historicalData.map(\.totalIntake).max() ?? 0
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        yesterdayIntake = historicalData.first(where: { calendar.isDate($0.date, inSameDayAs: yesterday) })?.totalIntake ?? 0
        if currentIntake > yesterdayIntake && currentIntake > 0 {
            achievementMessage = "🔥 You drank more than yesterday!"
        } else if streak >= 3 {
            achievementMessage = "🏅 Streak: \(streak) days!"
        } else if currentIntake >= dailyGoal {
            achievementMessage = "🎉 Goal achieved!"
        } else {
            achievementMessage = ""
        }
    }
}

struct WaterEntry: Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let timestamp: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var timeAgoString: String {
        let interval = Date().timeIntervalSince(timestamp)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        }
    }
}

struct DailyData: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let totalIntake: Double
    let entries: Int
    let goalMet: Bool
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
    
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var progressPercentage: Double {
        // Assuming default goal of 2500ml for historical data
        return min(totalIntake / 2500.0, 1.0)
    }
}

struct Statistics {
    let averageIntake: Double
    let bestDayIntake: Double
    let goalMetDays: Int
    let totalDays: Int
    
    var goalMetPercentage: Double {
        guard totalDays > 0 else { return 0 }
        return Double(goalMetDays) / Double(totalDays) * 100
    }
}

enum Timeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
} 
