//
//  MiniGameView.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct MiniGameView: View {
    @ObservedObject var sleepManager: SleepDataManager
    @State private var gameState: GameState = .menu
    @State private var animateContent = false
    
    enum GameState {
        case menu
        case playing
        case gameOver
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Night sky background
                NightSkyBackground()
                    .ignoresSafeArea()
                
                switch gameState {
                case .menu:
                    GameMenuView(
                        onStartGame: {
                            withAnimation(DreamAnimations.gentle) {
                                gameState = .playing
                            }
                        },
                        animate: animateContent
                    )
                    
                case .playing:
                    CatchTheZzzGameView(
                        sleepManager: sleepManager,
                        onGameOver: { stars in
                            sleepManager.addDreamStars(stars)
                            withAnimation(DreamAnimations.gentle) {
                                gameState = .gameOver
                            }
                        }
                    )
                    
                case .gameOver:
                    GameOverView(
                        onPlayAgain: {
                            withAnimation(DreamAnimations.gentle) {
                                gameState = .playing
                            }
                        },
                        onBackToMenu: {
                            withAnimation(DreamAnimations.gentle) {
                                gameState = .menu
                            }
                        }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            withAnimation(DreamAnimations.gentle.delay(0.3)) {
                animateContent = true
            }
        }
    }
}

struct GameMenuView: View {
    let onStartGame: () -> Void
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Game Title
            VStack(spacing: 16) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(DreamAnimations.bouncy.delay(0.2), value: animate)
                
                Text("Catch the Zzz")
                    .font(DreamTypography.largeTitle)
                    .foregroundColor(.white)
                    .offset(y: animate ? 0 : 20)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(DreamAnimations.gentle.delay(0.4), value: animate)
                
                Text("A relaxing mini-game to unwind before bed")
                    .font(DreamTypography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .offset(y: animate ? 0 : 20)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(DreamAnimations.gentle.delay(0.6), value: animate)
            }
            
            Spacer()
            
            // Instructions
            VStack(spacing: 20) {
                InstructionRow(
                    icon: "hand.point.left.fill",
                    text: "Move the moon left and right",
                    animate: animate,
                    delay: 0.8
                )
                
                InstructionRow(
                    icon: "zzz",
                    text: "Catch the floating Zzz bubbles",
                    animate: animate,
                    delay: 0.9
                )
                
                InstructionRow(
                    icon: "star.fill",
                    text: "Earn Dream Stars for your collection",
                    animate: animate,
                    delay: 1.0
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Start Button
            Button("Start Dreaming") {
                onStartGame()
            }
            .buttonStyle(DreamPrimaryButtonStyle())
            .padding(.horizontal, 30)
            .offset(y: animate ? 0 : 30)
            .opacity(animate ? 1.0 : 0.0)
            .animation(DreamAnimations.gentle.delay(1.2), value: animate)
            
            Spacer()
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    let animate: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.dreamPrimary)
                .frame(width: 30)
            
            Text(text)
                .font(DreamTypography.callout)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .offset(x: animate ? 0 : -30)
        .opacity(animate ? 1.0 : 0.0)
        .animation(DreamAnimations.gentle.delay(delay), value: animate)
    }
}

struct CatchTheZzzGameView: View {
    @ObservedObject var sleepManager: SleepDataManager
    let onGameOver: (Int) -> Void
    
    @State private var moonPosition: CGFloat = 0
    @State private var zzzBubbles: [ZzzBubble] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var isGameActive = true
    
    private let moonSize: CGFloat = 60
    private let bubbleSize: CGFloat = 40
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game UI
                VStack {
                    // Score and Lives
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.dreamPrimary)
                            Text("\(score)")
                                .font(DreamTypography.headline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .foregroundColor(index < lives ? .red : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                
                // Zzz Bubbles
                ForEach(zzzBubbles) { bubble in
                    ZzzBubbleView(bubble: bubble)
                        .position(x: bubble.x, y: bubble.y)
                        .onAppear {
                            animateBubble(bubble, in: geometry)
                        }
                }
                
                // Moon Character
                MoonCharacterView()
                    .position(
                        x: geometry.size.width / 2 + moonPosition,
                        y: geometry.size.height - 100
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPosition = value.translation.width
                                let maxOffset = (geometry.size.width / 2) - (moonSize / 2)
                                moonPosition = max(-maxOffset, min(maxOffset, newPosition))
                            }
                    )
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            stopGame()
        }
    }
    
    private func startGame() {
        isGameActive = true
        score = 0
        lives = 3
        zzzBubbles.removeAll()
        
        // Spawn bubbles every 1.5 seconds
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            if isGameActive {
                spawnZzzBubble()
            }
        }
        
        // Game update timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            if isGameActive {
                updateGame()
            }
        }
    }
    
    private func stopGame() {
        isGameActive = false
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
    }
    
    private func spawnZzzBubble() {
        let bubble = ZzzBubble(
            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
            y: -50
        )
        zzzBubbles.append(bubble)
    }
    
    private func animateBubble(_ bubble: ZzzBubble, in geometry: GeometryProxy) {
        withAnimation(.linear(duration: 4)) {
            if let index = zzzBubbles.firstIndex(where: { $0.id == bubble.id }) {
                zzzBubbles[index].y = geometry.size.height + 50
            }
        }
        
        // Remove bubble after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            zzzBubbles.removeAll { $0.id == bubble.id }
        }
    }
    
    private func updateGame() {
        let moonX = UIScreen.main.bounds.width / 2 + moonPosition
        let moonY = UIScreen.main.bounds.height - 100
        
        // Check collisions
        for (index, bubble) in zzzBubbles.enumerated() {
            let distance = sqrt(pow(bubble.x - moonX, 2) + pow(bubble.y - moonY, 2))
            
            if distance < (moonSize / 2 + bubbleSize / 2) {
                // Caught a bubble!
                score += 1
                zzzBubbles.remove(at: index)
                
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                break
            }
            
            // Check if bubble reached bottom
            if bubble.y > UIScreen.main.bounds.height + 50 {
                lives -= 1
                if lives <= 0 {
                    endGame()
                    return
                }
            }
        }
    }
    
    private func endGame() {
        stopGame()
        let starsEarned = max(1, score / 5) // 1 star per 5 points, minimum 1
        onGameOver(starsEarned)
    }
}

struct ZzzBubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
}

struct ZzzBubbleView: View {
    let bubble: ZzzBubble
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.dreamAccent.opacity(0.3),
                            Color.dreamAccent.opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
            
            Text("Zzz")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
}

struct MoonCharacterView: View {
    @State private var glow: Double = 0.8
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(glow * 0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
            
            // Moon character
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.dreamSunrise],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    // Moon face
                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.dreamNight)
                                .frame(width: 6, height: 6)
                            Circle()
                                .fill(Color.dreamNight)
                                .frame(width: 6, height: 6)
                        }
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.dreamNight)
                            .frame(width: 12, height: 3)
                    }
                )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glow = 1.2
            }
        }
    }
}

struct GameOverView: View {
    let onPlayAgain: () -> Void
    let onBackToMenu: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Game Over
            VStack(spacing: 20) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Sweet Dreams!")
                    .font(DreamTypography.largeTitle)
                    .foregroundColor(.white)
                
                Text("You've earned some Dream Stars for your constellation")
                    .font(DreamTypography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                Button("Play Again") {
                    onPlayAgain()
                }
                .buttonStyle(DreamPrimaryButtonStyle())
                
                Button("Back to Menu") {
                    onBackToMenu()
                }
                .buttonStyle(DreamSecondaryButtonStyle())
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct NightSkyBackground: View {
    @State private var starOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.dreamNight,
                    Color.dreamAccent.opacity(0.8),
                    Color.dreamNight
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated stars
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(Double.random(in: 0.5...1.0))
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: starOffset
                    )
            }
        }
        .onAppear {
            starOffset = 1
        }
    }
}

#Preview {
    MiniGameView(sleepManager: SleepDataManager())
}
