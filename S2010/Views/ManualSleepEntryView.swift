//
//  ManualSleepEntryView.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct ManualSleepEntryView: View {
    @ObservedObject var sleepManager: SleepDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var sleepHours: Double = 8.0
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
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.dreamAccent)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.bouncy.delay(0.2), value: animateContent)
                            
                            Text("Add Sleep Manually")
                                .font(DreamTypography.title)
                                .foregroundColor(.dreamNight)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.3), value: animateContent)
                            
                            Text("How many hours did you sleep?")
                                .font(DreamTypography.callout)
                                .foregroundColor(.dreamNight.opacity(0.7))
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(DreamAnimations.gentle.delay(0.4), value: animateContent)
                        }
                        .padding(.top, 20)
                        
                        // Sleep Hours Selector
                        VStack(spacing: 24) {
                            // Large display
                            VStack(spacing: 12) {
                                Text(String(format: "%.1f", sleepHours))
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.dreamPrimary)
                                
                                Text("hours")
                                    .font(DreamTypography.title2)
                                    .foregroundColor(.dreamNight.opacity(0.7))
                            }
                            .padding(24)
                            .dreamCard()
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.bouncy.delay(0.5), value: animateContent)
                            
                            // Slider
                            VStack(spacing: 16) {
                                Text("Adjust sleep duration")
                                    .font(DreamTypography.headline)
                                    .foregroundColor(.dreamNight)
                                
                                Slider(value: $sleepHours, in: 1.0...12.0, step: 0.5) {
                                    Text("Sleep Hours")
                                } minimumValueLabel: {
                                    Text("1h")
                                        .font(DreamTypography.caption)
                                        .foregroundColor(.dreamNight.opacity(0.6))
                                } maximumValueLabel: {
                                    Text("12h")
                                        .font(DreamTypography.caption)
                                        .foregroundColor(.dreamNight.opacity(0.6))
                                }
                                .accentColor(.dreamPrimary)
                                
                                // Quick selection buttons
                                HStack(spacing: 12) {
                                    ForEach([6.0, 7.0, 8.0, 9.0], id: \.self) { hours in
                                        Button("\(Int(hours))h") {
                                            withAnimation(DreamAnimations.quick) {
                                                sleepHours = hours
                                            }
                                        }
                                        .font(DreamTypography.callout)
                                        .foregroundColor(sleepHours == hours ? .white : .dreamAccent)
                                        .frame(width: 50, height: 36)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(sleepHours == hours ? Color.dreamAccent : Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 18)
                                                        .stroke(Color.dreamAccent, lineWidth: 1)
                                                )
                                        )
                                        .scaleEffect(sleepHours == hours ? 1.1 : 1.0)
                                        .animation(DreamAnimations.quick, value: sleepHours)
                                    }
                                }
                            }
                            .padding(20)
                            .dreamCard()
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.6), value: animateContent)
                        }
                        .padding(.horizontal, 20)
                        
                        // Quality indicator
                        SleepQualityIndicator(hours: sleepHours, goal: sleepManager.userStats.sleepGoal)
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(DreamAnimations.gentle.delay(0.7), value: animateContent)
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
        sleepManager.addManualSleepEntry(hoursSlept: sleepHours)
        
        // Add dream stars based on sleep quality
        let sleepQuality = sleepHours / sleepManager.userStats.sleepGoal
        let starsEarned = Int(sleepQuality * 5) // Up to 5 stars
        if starsEarned > 0 {
            sleepManager.addDreamStars(starsEarned)
        }
        
        dismiss()
    }
}

struct SleepQualityIndicator: View {
    let hours: Double
    let goal: Double
    
    private var qualityText: String {
        let percentage = hours / goal
        if percentage >= 1.0 {
            return "Perfect sleep! 🌟"
        } else if percentage >= 0.8 {
            return "Great sleep! 💫"
        } else if percentage >= 0.6 {
            return "Good sleep 🌙"
        } else {
            return "Try to get more rest ✨"
        }
    }
    
    private var qualityColor: Color {
        let percentage = hours / goal
        if percentage >= 0.8 {
            return .dreamPrimary
        } else if percentage >= 0.6 {
            return .dreamAccent
        } else {
            return .dreamNight.opacity(0.7)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(qualityColor)
                
                Text(qualityText)
                    .font(DreamTypography.headline)
                    .foregroundColor(qualityColor)
                
                Spacer()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.dreamSecondary.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [qualityColor.opacity(0.8), qualityColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(hours / goal, 1.0), height: 8)
                        .cornerRadius(4)
                        .animation(DreamAnimations.bouncy, value: hours)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .dreamCard()
    }
}

#Preview {
    ManualSleepEntryView(sleepManager: SleepDataManager())
}
