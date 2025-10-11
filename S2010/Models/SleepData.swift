//
//  SleepData.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import Foundation
import Combine

struct SleepEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let hoursSlept: Double
    let bedtime: Date
    let wakeTime: Date
    
    init(date: Date, hoursSlept: Double, bedtime: Date, wakeTime: Date) {
        self.id = UUID()
        self.date = date
        self.hoursSlept = hoursSlept
        self.bedtime = bedtime
        self.wakeTime = wakeTime
    }
}

struct UserStats: Codable {
    var sleepGoal: Double = 8.0
    var dreamStars: Int = 0
    var longestStreak: Int = 0
    var currentStreak: Int = 0
    var totalSleepEntries: Int = 0
}

struct ActiveSleepSession: Codable {
    let startTime: Date
    let id: UUID
    
    init(startTime: Date) {
        self.startTime = startTime
        self.id = UUID()
    }
}

class SleepDataManager: ObservableObject {
    @Published var sleepEntries: [SleepEntry] = []
    @Published var userStats: UserStats = UserStats()
    @Published var activeSleepSession: ActiveSleepSession? = nil
    
    private let sleepEntriesKey = "sleepEntries"
    private let userStatsKey = "userStats"
    private let activeSleepSessionKey = "activeSleepSession"
    
    init() {
        loadData()
    }
    
    func addSleepEntry(bedtime: Date, wakeTime: Date) {
        let hoursSlept = wakeTime.timeIntervalSince(bedtime) / 3600
        let entry = SleepEntry(
            date: Calendar.current.startOfDay(for: wakeTime),
            hoursSlept: hoursSlept,
            bedtime: bedtime,
            wakeTime: wakeTime
        )
        
        sleepEntries.append(entry)
        updateStats()
        saveData()
    }
    
    func updateSleepGoal(_ newGoal: Double) {
        userStats.sleepGoal = newGoal
        saveData()
    }
    
    func addDreamStars(_ stars: Int) {
        userStats.dreamStars += stars
        saveData()
    }
    
    func startSleepSession() {
        activeSleepSession = ActiveSleepSession(startTime: Date())
        saveData()
    }
    
    func endSleepSession() -> Double? {
        guard let session = activeSleepSession else { return nil }
        
        let endTime = Date()
        let hoursSlept = endTime.timeIntervalSince(session.startTime) / 3600
        
        // Create sleep entry
        let entry = SleepEntry(
            date: Calendar.current.startOfDay(for: endTime),
            hoursSlept: hoursSlept,
            bedtime: session.startTime,
            wakeTime: endTime
        )
        
        sleepEntries.append(entry)
        activeSleepSession = nil
        updateStats()
        saveData()
        
        return hoursSlept
    }
    
    func cancelSleepSession() {
        activeSleepSession = nil
        saveData()
    }
    
    func addManualSleepEntry(hoursSlept: Double) {
        let now = Date()
        let bedtime = Calendar.current.date(byAdding: .hour, value: -Int(hoursSlept), to: now) ?? now
        
        let entry = SleepEntry(
            date: Calendar.current.startOfDay(for: now),
            hoursSlept: hoursSlept,
            bedtime: bedtime,
            wakeTime: now
        )
        
        sleepEntries.append(entry)
        updateStats()
        saveData()
    }
    
    func resetProgress() {
        sleepEntries.removeAll()
        userStats = UserStats()
        saveData()
    }
    
    private func updateStats() {
        userStats.totalSleepEntries = sleepEntries.count
        
        // Calculate current streak
        let sortedEntries = sleepEntries.sorted { $0.date > $1.date }
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        
        let calendar = Calendar.current
        var expectedDate = calendar.startOfDay(for: Date())
        
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            
            if calendar.isDate(entryDate, inSameDayAs: expectedDate) {
                if entry.hoursSlept >= userStats.sleepGoal * 0.8 { // 80% of goal counts as success
                    tempStreak += 1
                    if currentStreak == 0 {
                        currentStreak = tempStreak
                    }
                } else {
                    break
                }
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate) ?? expectedDate
            } else {
                break
            }
        }
        
        // Calculate longest streak
        tempStreak = 0
        for entry in sleepEntries.sorted(by: { $0.date < $1.date }) {
            if entry.hoursSlept >= userStats.sleepGoal * 0.8 {
                tempStreak += 1
                longestStreak = max(longestStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }
        
        userStats.currentStreak = currentStreak
        userStats.longestStreak = longestStreak
    }
    
    func getAverageHoursSlept(days: Int = 7) -> Double {
        let recentEntries = sleepEntries
            .sorted { $0.date > $1.date }
            .prefix(days)
        
        guard !recentEntries.isEmpty else { return 0 }
        
        let totalHours = recentEntries.reduce(0) { $0 + $1.hoursSlept }
        return totalHours / Double(recentEntries.count)
    }
    
    func getRecentEntries(days: Int = 7) -> [SleepEntry] {
        return sleepEntries
            .sorted { $0.date > $1.date }
            .prefix(days)
            .reversed()
    }
    
    private func saveData() {
        if let encodedEntries = try? JSONEncoder().encode(sleepEntries) {
            UserDefaults.standard.set(encodedEntries, forKey: sleepEntriesKey)
        }
        
        if let encodedStats = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(encodedStats, forKey: userStatsKey)
        }
        
        if let session = activeSleepSession,
           let encodedSession = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encodedSession, forKey: activeSleepSessionKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeSleepSessionKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: sleepEntriesKey),
           let decodedEntries = try? JSONDecoder().decode([SleepEntry].self, from: data) {
            sleepEntries = decodedEntries
        }
        
        if let data = UserDefaults.standard.data(forKey: userStatsKey),
           let decodedStats = try? JSONDecoder().decode(UserStats.self, from: data) {
            userStats = decodedStats
        }
        
        if let data = UserDefaults.standard.data(forKey: activeSleepSessionKey),
           let decodedSession = try? JSONDecoder().decode(ActiveSleepSession.self, from: data) {
            activeSleepSession = decodedSession
        }
    }
}
