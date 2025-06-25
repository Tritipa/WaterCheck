//
//  ContentView.swift
//  WaterCheck
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var hydrationManager: HydrationManager
    @State private var showingAddWater = false
    @State private var selectedAmount: Double = 250
    
    private let waterAmounts: [Double] = [100, 150, 200, 250, 300, 350, 400, 500]
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedWaterBackground()
                LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.12), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                Color.white.opacity(0.01).ignoresSafeArea() 
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        headerView
                        quickAddSection
                        todayStatsView
                        recentEntriesView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 36)
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("💧 WaterCheck")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWater = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.blue)
                            .shadow(color: .cyan.opacity(0.18), radius: 6, x: 0, y: 2)
                    }
                }
            }
            .sheet(isPresented: $showingAddWater) {
                AddWaterView(selectedAmount: $selectedAmount)
            }
        }
    }
    
    // MARK: - Header (Progress)
    private var headerView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 220, height: 220)
                    .shadow(color: .blue.opacity(0.08), radius: 24, x: 0, y: 8)
                Circle()
                    .stroke(Color.blue.opacity(0.10), lineWidth: 24)
                    .frame(width: 220, height: 220)
                Circle()
                    .trim(from: 0, to: hydrationManager.progressPercentage)
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [Color.cyan, Color.blue, Color.cyan]), center: .center),
                        style: StrokeStyle(lineWidth: 24, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.7, dampingFraction: 0.8), value: hydrationManager.progressPercentage)
                VStack(spacing: 8) {
                    Text("\(Int(hydrationManager.currentIntake)) ml")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 1)
                    Text("of \(Int(hydrationManager.dailyGoal)) ml")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 2)
            Text(hydrationManager.progressMessage)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                .multilineTextAlignment(.center)
                .padding(.top, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
            if !hydrationManager.achievementMessage.isEmpty {
                Text(hydrationManager.achievementMessage)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.top, 2)
                    .transition(.opacity)
            }
            Text(hydrationManager.randomQuote())
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.10), radius: 24, x: 0, y: 8)
        )
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.4), value: hydrationManager.currentIntake)
    }
    
    // MARK: - Quick Add
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick Add")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                ForEach(waterAmounts, id: \.self) { amount in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            hydrationManager.addWater(amount: amount)
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                                .shadow(color: .cyan.opacity(0.18), radius: 4, x: 0, y: 2)
                            Text("\(Int(amount)) ml")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .shadow(color: Color.cyan.opacity(0.10), radius: 6, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.cyan.opacity(0.13), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
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
    
    // MARK: - Today Stats
    private var todayStatsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Today's Stats")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            HStack(spacing: 20) {
                StatCard(title: "Intake", value: "\(Int(hydrationManager.currentIntake)) ml", icon: "drop.fill", color: .blue)
                StatCard(title: "Goal", value: "\(Int(hydrationManager.dailyGoal)) ml", icon: "target", color: .green)
                StatCard(title: "Left", value: "\(Int(max(0, hydrationManager.dailyGoal - hydrationManager.currentIntake))) ml", icon: "minus.circle.fill", color: .orange)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.10), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Recent Entries
    private var recentEntriesView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recent Entries")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            if hydrationManager.todayEntries.isEmpty {
                Text("No entries yet today. Start hydrating!")
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 18)
            } else {
                ForEach(hydrationManager.todayEntries.prefix(5), id: \.id) { entry in
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
                                .shadow(color: .cyan.opacity(0.10), radius: 4, x: 0, y: 2)
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(Int(entry.amount)) ml")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            Text(entry.timeString)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(entry.timeAgoString)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    if entry.id != hydrationManager.todayEntries.prefix(5).last?.id {
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.18), radius: 4, x: 0, y: 2)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

struct AnimatedWaterBackground: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let midY = height * 0.7
                let amplitude: CGFloat = 18
                let waveLength: CGFloat = width / 1.2
                let speed: CGFloat = 0.8
                var path = Path()
                path.move(to: CGPoint(x: 0, y: midY))
                for x in stride(from: 0, through: width, by: 2) {
                    let relativeX = x / waveLength
                    let sine = sin(relativeX * .pi * 2 + phase)
                    let y = midY + sine * amplitude
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
                context.fill(path, with: .linearGradient(
                    Gradient(colors: [Color.cyan.opacity(0.22), Color.blue.opacity(0.18)]),
                    startPoint: CGPoint(x: 0, y: midY),
                    endPoint: CGPoint(x: 0, y: height)
                ))
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 0.0)) {
                    phase = 0
                }
            }
            .onChange(of: phase) { _ in }
            .onReceive(Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()) { _ in
                withAnimation(.linear(duration: 1/60)) {
                    phase += 0.03
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HydrationManager())
}
