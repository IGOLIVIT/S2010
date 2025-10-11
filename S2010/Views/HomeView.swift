//
//  HomeView.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var sleepManager: SleepDataManager
    @State private var showingManualEntry = false
    @State private var animateContent = false
    @State private var backgroundOffset: CGFloat = 0
    @State private var showingEndSleepAlert = false
    @State private var sleepDuration: Double = 0
    
    private var todaysSleep: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return sleepManager.sleepEntries
            .first { Calendar.current.isDate($0.date, inSameDayAs: today) }?
            .hoursSlept ?? 0
    }
    
    private var progressPercentage: Double {
        min(todaysSleep / sleepManager.userStats.sleepGoal, 1.0)
    }
    
    private var currentSleepDuration: Double {
        guard let session = sleepManager.activeSleepSession else { return 0 }
        return Date().timeIntervalSince(session.startTime) / 3600
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
                AnimatedBackground(offset: backgroundOffset)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Dream Rhythm")
                                .font(DreamTypography.largeTitle)
                                .foregroundColor(.dreamNight)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : -20)
                                .animation(DreamAnimations.gentle.delay(0.2), value: animateContent)
                            
                            Text(DateFormatter.dayFormatter.string(from: Date()))
                                .font(DreamTypography.callout)
                                .foregroundColor(.dreamNight.opacity(0.7))
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : -20)
                                .animation(DreamAnimations.gentle.delay(0.3), value: animateContent)
                        }
                        .padding(.top, 20)
                        
                        // Main Sleep Control
                        if let session = sleepManager.activeSleepSession {
                            // Active sleep session
                            ActiveSleepView(
                                session: session,
                                currentDuration: currentSleepDuration,
                                onEndSleep: {
                                    if let duration = sleepManager.endSleepSession() {
                                        sleepDuration = duration
                                        showingEndSleepAlert = true
                                    }
                                },
                                onCancel: {
                                    sleepManager.cancelSleepSession()
                                }
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.bouncy.delay(0.4), value: animateContent)
                        } else {
                            // No active session
                            SleepControlView(
                                todaysSleep: todaysSleep,
                                goal: sleepManager.userStats.sleepGoal,
                                progressPercentage: progressPercentage,
                                onStartSleep: {
                                    sleepManager.startSleepSession()
                                },
                                onManualEntry: {
                                    showingManualEntry = true
                                }
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.bouncy.delay(0.4), value: animateContent)
                        }
                        
                        // Sleep Goal Section
                        SleepGoalCard(sleepManager: sleepManager)
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.6), value: animateContent)
                            .padding(.horizontal, 20)
                        
                        // Dream Stars Display
                        if sleepManager.userStats.dreamStars > 0 {
                            DreamStarsView(stars: sleepManager.userStats.dreamStars)
                                .offset(y: animateContent ? 0 : 30)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.8), value: animateContent)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualSleepEntryView(sleepManager: sleepManager)
        }
        .alert("Sleep Completed! 😴", isPresented: $showingEndSleepAlert) {
            Button("Great!") { }
        } message: {
            Text("You slept for \(String(format: "%.1f", sleepDuration)) hours. Sweet dreams! 🌙")
        }
        .onAppear {
            withAnimation {
                animateContent = true
            }
            startBackgroundAnimation()
        }
    }
    
    private func startBackgroundAnimation() {
        withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
            backgroundOffset = 360
        }
    }
}

struct SleepControlView: View {
    let todaysSleep: Double
    let goal: Double
    let progressPercentage: Double
    let onStartSleep: () -> Void
    let onManualEntry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Today's Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.dreamSecondary.opacity(0.3), lineWidth: 12)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [Color.dreamPrimary, Color.dreamAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(DreamAnimations.bouncy.delay(0.5), value: progressPercentage)
                
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", todaysSleep))
                        .font(DreamTypography.largeTitle)
                        .foregroundColor(.dreamNight)
                    
                    Text("hours today")
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.7))
                    
                    Text("Goal: \(String(format: "%.0f", goal))h")
                        .font(DreamTypography.footnote)
                        .foregroundColor(.dreamNight.opacity(0.5))
                }
            }
            .dreamCard()
            .padding(20)
            
            // Action Buttons
            VStack(spacing: 16) {
                Button {
                    onStartSleep()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.fill")
                            .font(.title2)
                        Text("Start Sleep")
                            .font(DreamTypography.headline)
                    }
                }
                .buttonStyle(DreamPrimaryButtonStyle())
                
                Button {
                    onManualEntry()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                        Text("Add Sleep Manually")
                            .font(DreamTypography.headline)
                    }
                }
                .buttonStyle(DreamSecondaryButtonStyle())
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ActiveSleepView: View {
    let session: ActiveSleepSession
    let currentDuration: Double
    let onEndSleep: () -> Void
    let onCancel: () -> Void
    
    @State private var timer: Timer?
    @State private var displayDuration: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Sleep Timer Display
            VStack(spacing: 16) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.dreamAccent)
                    .scaleEffect(1.0)
                    .animation(
                        Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: displayDuration
                    )
                
                Text("Sleeping...")
                    .font(DreamTypography.title)
                    .foregroundColor(.dreamNight)
                
                VStack(spacing: 4) {
                    Text(formatDuration(displayDuration))
                        .font(DreamTypography.largeTitle)
                        .foregroundColor(.dreamPrimary)
                        .fontWeight(.bold)
                    
                    Text("Started at \(DateFormatter.timeFormatter.string(from: session.startTime))")
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
            }
            .padding(24)
            .dreamCard()
            .padding(.horizontal, 20)
            
            // Control Buttons
            HStack(spacing: 16) {
                Button {
                    onCancel()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                        Text("Cancel")
                            .font(DreamTypography.headline)
                    }
                }
                .buttonStyle(DreamSecondaryButtonStyle())
                
                Button {
                    onEndSleep()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.title3)
                        Text("Wake Up")
                            .font(DreamTypography.headline)
                    }
                }
                .buttonStyle(DreamPrimaryButtonStyle())
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        displayDuration = currentDuration
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            displayDuration = Date().timeIntervalSince(session.startTime) / 3600
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatDuration(_ hours: Double) -> String {
        let totalMinutes = Int(hours * 60)
        let displayHours = totalMinutes / 60
        let displayMinutes = totalMinutes % 60
        
        if displayHours > 0 {
            return "\(displayHours)h \(displayMinutes)m"
        } else {
            return "\(displayMinutes)m"
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let hoursSlept: Double
    let goal: Double
    let animate: Bool
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.dreamSecondary.opacity(0.3), lineWidth: 12)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animate ? progress : 0)
                .stroke(
                    LinearGradient(
                        colors: [Color.dreamPrimary, Color.dreamAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(DreamAnimations.bouncy.delay(0.5), value: animate)
            
            // Center content
            VStack(spacing: 8) {
                Text(String(format: "%.1f", hoursSlept))
                    .font(DreamTypography.largeTitle)
                    .foregroundColor(.dreamNight)
                
                Text("hours")
                    .font(DreamTypography.callout)
                    .foregroundColor(.dreamNight.opacity(0.7))
                
                Text("of \(String(format: "%.0f", goal))")
                    .font(DreamTypography.footnote)
                    .foregroundColor(.dreamNight.opacity(0.5))
            }
            .scaleEffect(animate ? 1.0 : 0.8)
            .opacity(animate ? 1.0 : 0.0)
            .animation(DreamAnimations.bouncy.delay(0.8), value: animate)
        }
        .dreamCard()
        .padding(20)
    }
}

struct SleepGoalCard: View {
    @ObservedObject var sleepManager: SleepDataManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sleep Goal")
                .font(DreamTypography.headline)
                .foregroundColor(.dreamNight)
            
            HStack(spacing: 20) {
                Button {
                    if sleepManager.userStats.sleepGoal > 4.0 {
                        sleepManager.updateSleepGoal(sleepManager.userStats.sleepGoal - 0.5)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.dreamAccent)
                }
                .buttonStyle(DreamIconButtonStyle())
                
                Text("\(String(format: "%.1f", sleepManager.userStats.sleepGoal)) hours")
                    .font(DreamTypography.title2)
                    .foregroundColor(.dreamNight)
                    .frame(minWidth: 120)
                
                Button {
                    if sleepManager.userStats.sleepGoal < 12.0 {
                        sleepManager.updateSleepGoal(sleepManager.userStats.sleepGoal + 0.5)
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.dreamAccent)
                }
                .buttonStyle(DreamIconButtonStyle())
            }
        }
        .padding(20)
        .dreamCard()
    }
}

struct DreamStarsView: View {
    let stars: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Dream Stars Collected")
                .font(DreamTypography.headline)
                .foregroundColor(.dreamNight)
            
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.dreamPrimary)
                    .font(.title2)
                
                Text("\(stars)")
                    .font(DreamTypography.title2)
                    .foregroundColor(.dreamNight)
                    .fontWeight(.semibold)
            }
        }
        .padding(20)
        .dreamCard()
    }
}

struct AnimatedBackground: View {
    let offset: CGFloat
    
    var body: some View {
        ZStack {
            Color.dreamBackground
            
            // Floating elements
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.dreamPrimary.opacity(0.1), Color.dreamAccent.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 60...120))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .rotationEffect(.degrees(offset + Double(index * 45)))
            }
        }
    }
}

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

#Preview {
    HomeView(sleepManager: SleepDataManager())
}
