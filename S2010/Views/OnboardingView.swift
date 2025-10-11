//
//  OnboardingView.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateContent = false
    @Binding var showOnboarding: Bool
    
    private let pages = [
        OnboardingPage(
            title: "Restore your sleep rhythm",
            description: "Transform your nights into a journey of self-improvement and discover the power of quality rest.",
            systemImage: "moon.stars.fill",
            color: Color.dreamAccent
        ),
        OnboardingPage(
            title: "Track your progress and wake up refreshed",
            description: "Monitor your sleep patterns, set goals, and celebrate every step toward better health.",
            systemImage: "chart.line.uptrend.xyaxis",
            color: Color.dreamPrimary
        ),
        OnboardingPage(
            title: "Turn rest into a skill",
            description: "Master the art of sleep with gentle games, insights, and rewards that make bedtime something to look forward to.",
            systemImage: "star.fill",
            color: Color.dreamNight
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background gradient
                DreamGradients.dayNight
                    .ignoresSafeArea()
                    .animation(DreamAnimations.slow, value: currentPage)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isActive: currentPage == index,
                            animateContent: animateContent
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentPage) { newValue in
                    withAnimation(DreamAnimations.gentle) {
                        animateContent = true
                    }
                }
                
                VStack {
                    Spacer()
                    
                    // Page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 10, height: 10)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(DreamAnimations.bouncy, value: currentPage)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation(DreamAnimations.gentle) {
                                    currentPage -= 1
                                }
                            }
                            .buttonStyle(DreamSecondaryButtonStyle())
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 1 ? "Start Journey" : "Next") {
                            if currentPage == pages.count - 1 {
                                withAnimation(DreamAnimations.gentle) {
                                    showOnboarding = false
                                    NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                                }
                            } else {
                                withAnimation(DreamAnimations.gentle) {
                                    currentPage += 1
                                }
                            }
                        }
                        .buttonStyle(DreamPrimaryButtonStyle())
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            withAnimation(DreamAnimations.gentle.delay(0.3)) {
                animateContent = true
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let animateContent: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.systemImage)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.white)
                .scaleEffect(isActive && animateContent ? 1.0 : 0.8)
                .opacity(isActive && animateContent ? 1.0 : 0.6)
                .animation(DreamAnimations.bouncy.delay(0.2), value: animateContent)
            
            VStack(spacing: 20) {
                // Title
                Text(page.title)
                    .font(DreamTypography.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .offset(y: isActive && animateContent ? 0 : 30)
                    .opacity(isActive && animateContent ? 1.0 : 0.0)
                    .animation(DreamAnimations.gentle.delay(0.4), value: animateContent)
                
                // Description
                Text(page.description)
                    .font(DreamTypography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .offset(y: isActive && animateContent ? 0 : 30)
                    .opacity(isActive && animateContent ? 1.0 : 0.0)
                    .animation(DreamAnimations.gentle.delay(0.6), value: animateContent)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
