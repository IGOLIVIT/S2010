//
//  InsightsView.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct InsightsView: View {
    @ObservedObject var sleepManager: SleepDataManager
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var animateContent = false
    @State private var showingResetAlert = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            }
        }
    }
    
    private var recentEntries: [SleepEntry] {
        sleepManager.getRecentEntries(days: selectedTimeframe.days)
    }
    
    private var averageHours: Double {
        sleepManager.getAverageHoursSlept(days: selectedTimeframe.days)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dreamBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Progress & Trends")
                                .font(DreamTypography.title)
                                .foregroundColor(.dreamNight)
                                .offset(y: animateContent ? 0 : -20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.2), value: animateContent)
                            
                            Text("Your sleep journey insights")
                                .font(DreamTypography.callout)
                                .foregroundColor(.dreamNight.opacity(0.7))
                                .offset(y: animateContent ? 0 : -20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.3), value: animateContent)
                        }
                        .padding(.top, 20)
                        
                        // Stats Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Average Sleep",
                                value: String(format: "%.1f hrs", averageHours),
                                icon: "moon.stars.fill",
                                color: .dreamAccent
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.4), value: animateContent)
                            
                            StatCard(
                                title: "Current Streak",
                                value: "\(sleepManager.userStats.currentStreak) days",
                                icon: "flame.fill",
                                color: .dreamPrimary
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.5), value: animateContent)
                            
                            StatCard(
                                title: "Longest Streak",
                                value: "\(sleepManager.userStats.longestStreak) days",
                                icon: "trophy.fill",
                                color: .dreamNight
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.6), value: animateContent)
                            
                            StatCard(
                                title: "Dream Stars",
                                value: "\(sleepManager.userStats.dreamStars)",
                                icon: "star.fill",
                                color: .dreamPrimary
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.7), value: animateContent)
                        }
                        .padding(.horizontal, 20)
                        
                        // Chart Section
                        VStack(spacing: 20) {
                            // Timeframe Picker
                            Picker("Timeframe", selection: $selectedTimeframe) {
                                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                                    Text(timeframe.rawValue).tag(timeframe)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.8), value: animateContent)
                            
                            // Sleep Chart
                            SleepChartView(
                                entries: recentEntries,
                                goal: sleepManager.userStats.sleepGoal,
                                animate: animateContent
                            )
                            .padding(.horizontal, 20)
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.9), value: animateContent)
                        }
                        
                        // Dream Stars Constellation
                        if sleepManager.userStats.dreamStars > 0 {
                            DreamConstellationView(stars: sleepManager.userStats.dreamStars)
                                .padding(.horizontal, 20)
                                .offset(y: animateContent ? 0 : 30)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(1.0), value: animateContent)
                        }
                        
                        // Reset Button
                        Button("Reset Progress") {
                            showingResetAlert = true
                        }
                        .buttonStyle(DreamSecondaryButtonStyle())
                        .padding(.horizontal, 20)
                        .offset(y: animateContent ? 0 : 30)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(DreamAnimations.gentle.delay(1.1), value: animateContent)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                sleepManager.resetProgress()
            }
        } message: {
            Text("This will permanently delete all your sleep data and statistics. This action cannot be undone.")
        }
        .onAppear {
            withAnimation {
                animateContent = true
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(DreamTypography.title2)
                .foregroundColor(.dreamNight)
                .fontWeight(.semibold)
            
            Text(title)
                .font(DreamTypography.caption)
                .foregroundColor(.dreamNight.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .dreamCard()
    }
}

struct SleepChartView: View {
    let entries: [SleepEntry]
    let goal: Double
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sleep Hours Trend")
                .font(DreamTypography.headline)
                .foregroundColor(.dreamNight)
            
            if entries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.dreamSecondary)
                    
                    Text("No sleep data yet")
                        .font(DreamTypography.body)
                        .foregroundColor(.dreamNight.opacity(0.6))
                    
                    Text("Start logging your sleep to see trends!")
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            } else {
                // Simple custom chart
                GeometryReader { geometry in
                    let maxHours = max(entries.map { $0.hoursSlept }.max() ?? 8, goal)
                    let chartWidth = geometry.size.width
                    let chartHeight: CGFloat = 160
                    let pointSpacing = chartWidth / CGFloat(max(entries.count - 1, 1))
                    
                    ZStack {
                        // Background grid
                        VStack(spacing: 0) {
                            ForEach(0..<5, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.dreamSecondary.opacity(0.3))
                                    .frame(height: 1)
                                Spacer()
                            }
                        }
                        .frame(height: chartHeight)
                        
                        // Goal line
                        Rectangle()
                            .fill(Color.dreamAccent.opacity(0.6))
                            .frame(height: 2)
                            .offset(y: chartHeight/2 - CGFloat(goal/maxHours) * chartHeight)
                        
                        // Data points and line
                        Path { path in
                            for (index, entry) in entries.enumerated() {
                                let x = CGFloat(index) * pointSpacing
                                let y = chartHeight - (CGFloat(animate ? entry.hoursSlept : 0) / maxHours) * chartHeight
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [Color.dreamPrimary, Color.dreamAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .animation(DreamAnimations.bouncy.delay(0.5), value: animate)
                        
                        // Data points
                        ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                            Circle()
                                .fill(Color.dreamPrimary)
                                .frame(width: 8, height: 8)
                                .position(
                                    x: CGFloat(index) * pointSpacing,
                                    y: chartHeight - (CGFloat(animate ? entry.hoursSlept : 0) / maxHours) * chartHeight
                                )
                                .scaleEffect(animate ? 1.0 : 0.0)
                                .animation(DreamAnimations.bouncy.delay(0.5 + Double(index) * 0.1), value: animate)
                        }
                        
                        // Y-axis labels
                        VStack {
                            ForEach(0..<5, id: \.self) { index in
                                HStack {
                                    Text(String(format: "%.0f", maxHours * (1.0 - Double(index) / 4.0)))
                                        .font(DreamTypography.caption)
                                        .foregroundColor(.dreamNight.opacity(0.7))
                                    Spacer()
                                }
                                if index < 4 { Spacer() }
                            }
                        }
                        .frame(height: chartHeight)
                        
                        // X-axis labels
                        VStack {
                            Spacer()
                            HStack {
                                ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                                    Text(DateFormatter.shortDay.string(from: entry.date))
                                        .font(DreamTypography.caption)
                                        .foregroundColor(.dreamNight.opacity(0.7))
                                    
                                    if index < entries.count - 1 {
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .frame(height: chartHeight)
                    }
                }
                .frame(height: 200)
                
                // Goal line reference
                HStack {
                    Rectangle()
                        .fill(Color.dreamAccent.opacity(0.6))
                        .frame(width: 20, height: 2)
                    
                    Text("Goal: \(String(format: "%.1f", goal)) hours")
                        .font(DreamTypography.footnote)
                        .foregroundColor(.dreamNight.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .dreamCard()
    }
}

struct DreamConstellationView: View {
    let stars: Int
    
    private var starPositions: [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let maxStars = min(stars, 20) // Limit to 20 stars for visual appeal
        
        for i in 0..<maxStars {
            let angle = Double(i) * (2 * Double.pi / Double(maxStars))
            let radius = CGFloat(60 + (i % 3) * 20) // Varying radius for constellation effect
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            positions.append((x: x, y: y))
        }
        
        return positions
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Dream Constellation")
                .font(DreamTypography.headline)
                .foregroundColor(.dreamNight)
            
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.dreamNight.opacity(0.1),
                                Color.dreamAccent.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                
                // Stars
                ForEach(Array(starPositions.enumerated()), id: \.offset) { index, position in
                    Image(systemName: "star.fill")
                        .font(.system(size: CGFloat.random(in: 12...20)))
                        .foregroundColor(Color.dreamPrimary.opacity(Double.random(in: 0.7...1.0)))
                        .offset(x: position.x, y: position.y)
                        .scaleEffect(Double.random(in: 0.8...1.2))
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                            value: stars
                        )
                }
            }
            .frame(height: 240)
            
            Text("\(stars) stars collected from your sleep journey")
                .font(DreamTypography.callout)
                .foregroundColor(.dreamNight.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .dreamCard()
    }
}

extension DateFormatter {
    static let shortDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
}

#Preview {
    InsightsView(sleepManager: SleepDataManager())
}
