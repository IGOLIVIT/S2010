//
//  SleepLoggerView.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct SleepLoggerView: View {
    @ObservedObject var sleepManager: SleepDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var bedtime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var wakeTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var animateContent = false
    
    private var hoursSlept: Double {
        var adjustedWakeTime = wakeTime
        if wakeTime < bedtime {
            adjustedWakeTime = Calendar.current.date(byAdding: .day, value: 1, to: wakeTime) ?? wakeTime
        }
        let interval = adjustedWakeTime.timeIntervalSince(bedtime)
        return max(0, interval / 3600)
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
                            Image(systemName: "bed.double.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.dreamAccent)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.bouncy.delay(0.2), value: animateContent)
                            
                            Text("Log Your Sleep")
                                .font(DreamTypography.title)
                                .foregroundColor(.dreamNight)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.3), value: animateContent)
                            
                            Text("Track last night's rest")
                                .font(DreamTypography.callout)
                                .foregroundColor(.dreamNight.opacity(0.7))
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.4), value: animateContent)
                        }
                        .padding(.top, 20)
                        
                        // Sleep Duration Display
                        VStack(spacing: 16) {
                            Text("Sleep Duration")
                                .font(DreamTypography.headline)
                                .foregroundColor(.dreamNight)
                            
                            Text(String(format: "%.1f hours", hoursSlept))
                                .font(DreamTypography.largeTitle)
                                .foregroundColor(.dreamPrimary)
                                .fontWeight(.bold)
                            
                            Text(hoursSlept >= sleepManager.userStats.sleepGoal ? "Great job! 🌟" : "Every hour counts! 💫")
                                .font(DreamTypography.callout)
                                .foregroundColor(.dreamNight.opacity(0.7))
                        }
                        .padding(24)
                        .dreamCard()
                        .padding(.horizontal, 20)
                        .offset(y: animateContent ? 0 : 30)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(DreamAnimations.gentle.delay(0.5), value: animateContent)
                        
                        // Time Pickers
                        VStack(spacing: 24) {
                            // Bedtime
                            TimePickerCard(
                                title: "Bedtime",
                                icon: "moon.fill",
                                color: .dreamAccent,
                                time: $bedtime
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.6), value: animateContent)
                            
                            // Wake Time
                            TimePickerCard(
                                title: "Wake Time",
                                icon: "sun.max.fill",
                                color: .dreamPrimary,
                                time: $wakeTime
                            )
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.7), value: animateContent)
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button("Save Sleep Entry") {
                            saveSleepEntry()
                        }
                        .buttonStyle(DreamPrimaryButtonStyle())
                        .padding(.horizontal, 20)
                        .offset(y: animateContent ? 0 : 30)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(DreamAnimations.gentle.delay(0.8), value: animateContent)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.dreamAccent)
                }
            }
        }
        .onAppear {
            withAnimation {
                animateContent = true
            }
        }
    }
    
    private func saveSleepEntry() {
        // Adjust dates if wake time is before bedtime (next day)
        var adjustedWakeTime = wakeTime
        if wakeTime < bedtime {
            adjustedWakeTime = Calendar.current.date(byAdding: .day, value: 1, to: wakeTime) ?? wakeTime
        }
        
        sleepManager.addSleepEntry(bedtime: bedtime, wakeTime: adjustedWakeTime)
        
        // Add dream stars based on sleep quality
        let sleepQuality = hoursSlept / sleepManager.userStats.sleepGoal
        let starsEarned = Int(sleepQuality * 5) // Up to 5 stars
        if starsEarned > 0 {
            sleepManager.addDreamStars(starsEarned)
        }
        
        dismiss()
    }
}

struct TimePickerCard: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var time: Date
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(DreamTypography.headline)
                    .foregroundColor(.dreamNight)
                
                Spacer()
            }
            
            DatePicker(
                "",
                selection: $time,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
        }
        .padding(20)
        .dreamCard()
    }
}

#Preview {
    SleepLoggerView(sleepManager: SleepDataManager())
}
