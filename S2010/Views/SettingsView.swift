//
//  SettingsView.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var sleepManager: SleepDataManager
    @State private var showingInsights = false
    @State private var showingResetAlert = false
    @State private var animateContent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dreamBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.dreamAccent)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.bouncy.delay(0.2), value: animateContent)
                            
                            Text("Settings")
                                .font(DreamTypography.title)
                                .foregroundColor(.dreamNight)
                                .offset(y: animateContent ? 0 : -20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.3), value: animateContent)
                            
                            Text("Customize your Dream Rhythm experience")
                                .font(DreamTypography.callout)
                                .foregroundColor(.dreamNight.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : -20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.4), value: animateContent)
                        }
                        .padding(.top, 20)
                        
                        // Settings Options
                        VStack(spacing: 20) {
                            // View Statistics
                            SettingsCard(
                                title: "View My Statistics",
                                subtitle: "See your sleep trends and progress",
                                icon: "chart.bar.fill",
                                color: .dreamAccent,
                                action: {
                                    showingInsights = true
                                }
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.5), value: animateContent)
                            
                            // Sleep Goal
                            SleepGoalSettingsCard(sleepManager: sleepManager)
                                .offset(y: animateContent ? 0 : 30)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.6), value: animateContent)
                            
                            // App Info
                            AppInfoCard()
                                .offset(y: animateContent ? 0 : 30)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.7), value: animateContent)
                            
                            // Reset Progress
                            SettingsCard(
                                title: "Reset Progress",
                                subtitle: "Clear all sleep data and start fresh",
                                icon: "arrow.clockwise.circle.fill",
                                color: .red,
                                action: {
                                    showingResetAlert = true
                                }
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.8), value: animateContent)
                        }
                        .padding(.horizontal, 20)
                        
                        // Dream Stars Summary
                        if sleepManager.userStats.dreamStars > 0 {
                            DreamStarsSummaryCard(sleepManager: sleepManager)
                                .offset(y: animateContent ? 0 : 30)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.9), value: animateContent)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingInsights) {
            InsightsView(sleepManager: sleepManager)
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                sleepManager.resetProgress()
            }
        } message: {
            Text("This will permanently delete all your sleep data, statistics, and Dream Stars. This action cannot be undone.")
        }
        .onAppear {
            withAnimation {
                animateContent = true
            }
        }
    }
}

struct SettingsCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.1))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DreamTypography.headline)
                        .foregroundColor(.dreamNight)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.dreamNight.opacity(0.5))
            }
            .padding(20)
            .dreamCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SleepGoalSettingsCard: View {
    @ObservedObject var sleepManager: SleepDataManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.dreamPrimary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.dreamPrimary.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Goal")
                        .font(DreamTypography.headline)
                        .foregroundColor(.dreamNight)
                    
                    Text("Set your nightly sleep target")
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
                
                Spacer()
            }
            
            // Goal Adjuster
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
                
                VStack(spacing: 4) {
                    Text("\(String(format: "%.1f", sleepManager.userStats.sleepGoal))")
                        .font(DreamTypography.title)
                        .foregroundColor(.dreamNight)
                        .fontWeight(.semibold)
                    
                    Text("hours")
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
                .frame(minWidth: 80)
                
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

struct AppInfoCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.dreamAccent)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.dreamAccent.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("About Dream Rhythm")
                        .font(DreamTypography.headline)
                        .foregroundColor(.dreamNight)
                    
                    Text("Version 1.0")
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Dream Rhythm helps you develop healthy sleep habits through tracking, insights, and relaxing mini-games.")
                    .font(DreamTypography.callout)
                    .foregroundColor(.dreamNight.opacity(0.8))
                
                Text("Turn proper sleep into an engaging self-improvement experience with routines, statistics, and Dream Stars.")
                    .font(DreamTypography.callout)
                    .foregroundColor(.dreamNight.opacity(0.8))
            }
        }
        .padding(20)
        .dreamCard()
    }
}

struct DreamStarsSummaryCard: View {
    @ObservedObject var sleepManager: SleepDataManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.dreamPrimary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.dreamPrimary.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dream Stars Collection")
                        .font(DreamTypography.headline)
                        .foregroundColor(.dreamNight)
                    
                    Text("Your sleep journey rewards")
                        .font(DreamTypography.callout)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
                
                Spacer()
            }
            
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("\(sleepManager.userStats.dreamStars)")
                        .font(DreamTypography.title)
                        .foregroundColor(.dreamPrimary)
                        .fontWeight(.bold)
                    
                    Text("Total Stars")
                        .font(DreamTypography.caption)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
                
                VStack(spacing: 8) {
                    Text("\(sleepManager.userStats.currentStreak)")
                        .font(DreamTypography.title)
                        .foregroundColor(.dreamAccent)
                        .fontWeight(.bold)
                    
                    Text("Day Streak")
                        .font(DreamTypography.caption)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
                
                VStack(spacing: 8) {
                    Text("\(sleepManager.userStats.totalSleepEntries)")
                        .font(DreamTypography.title)
                        .foregroundColor(.dreamNight)
                        .fontWeight(.bold)
                    
                    Text("Nights Logged")
                        .font(DreamTypography.caption)
                        .foregroundColor(.dreamNight.opacity(0.7))
                }
            }
        }
        .padding(20)
        .dreamCard()
    }
}

#Preview {
    SettingsView(sleepManager: SleepDataManager())
}
