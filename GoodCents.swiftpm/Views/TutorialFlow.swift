//
//  TutorialFlow.swift
//  GoodCents
//
//  Created by GoodCents on 10/01/2025.
//

import SwiftUI

struct TutorialFlow: View {
    @State var tutorialStage: Int
    @State var selectedTutorialTab: Int
    
    @AppStorage("completedTutorial") var completedTutorial: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea(.all, edges: .top)
                .padding(.bottom, 49)
                .zIndex(1)
            
            if tutorialStage == 1 {
                tutorialStage1()
            } else if tutorialStage == 2 {
                tutorialStage2()
            } else if tutorialStage == 3 {
                tutorialStage3()
            } else if tutorialStage == 4 {
                tutorialStage4()
            } else if tutorialStage == 5 {
                tutorialStageFinished()
            }
            
            TabView(selection: $selectedTutorialTab) {
                Tab("Home", systemImage: "house", value: 1) {
                    Home()
                }
                
                if tutorialStage >= 2 {
                    Tab("Lessons", systemImage: "graduationcap.fill", value: 2) {
                        LessonMainView()
                    }
                }
                
                if tutorialStage >= 3 {
                    Tab("Job", systemImage: "person", value: 3) {
                        JobOverview()
                    }
                }
                
                if tutorialStage >= 4 {
                    Tab("Goals", systemImage: "circle.dashed", value: 4) {
                        GoalView()
                    }
                }
            }
            .onChange(of: tutorialStage) {
                if tutorialStage == 5 {
                    selectedTutorialTab = 1
                } else {
                    selectedTutorialTab = tutorialStage
                }
            }
            .onChange(of: selectedTutorialTab) {
                if selectedTutorialTab != 1 || tutorialStage != 5 {
                    selectedTutorialTab = tutorialStage
                }
            }
            .onAppear {
                selectedTutorialTab = tutorialStage
            }
        }
    }
    
// MARK: - Tutorial Stage 1 (Home)
    @ViewBuilder
    func tutorialStage1() -> some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: UIScreen.main.bounds.width / 1.2, height: 200)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 2)
                    )
                
                VStack(spacing: 16) {
                    Spacer()
                    Text("Welcome to your home page! Here you can see your current balance, transfer money and progress time.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal)
                    
                    Button(action: {
                        tutorialStage = 2
                    }) {
                        Text("Next")
                            .bold()
                            .padding(.vertical, 7)
                            .padding(.horizontal, 40)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width / 1.3, height: 180)
                .multilineTextAlignment(.center)
            }
            
            Image(systemName: "arrow.down")
                .font(.system(size: 60))
                .foregroundStyle(.thinMaterial)
                .symbolEffect(.wiggle)
        }
        .zIndex(2)
        .padding(.bottom, 70)
    }
    
// MARK: - Tutorial Stage 2 (Lessons)
    @ViewBuilder
    func tutorialStage2() -> some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: UIScreen.main.bounds.width / 1.2, height: 200)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 2)
                    )
                
                VStack(spacing: 16) {
                    Text("Welcome to the lessons page! Here you can learn money skills and take quizzes to test your knowledge.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 1)
                        .lineLimit(nil)
                    
                    Button(action: {
                        tutorialStage = 3
                    }) {
                        Text("Next")
                            .bold()
                            .padding(.vertical, 7)
                            .padding(.horizontal, 40)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 1.3, height: 180)
                .multilineTextAlignment(.center)
            }
            
            HStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .font(.system(size: 60))
                    .foregroundStyle(.thinMaterial)
                    .symbolEffect(.wiggle)
            }
            .padding(.trailing, 67)
            
//            HStack {
//                Spacer()
//                Image(systemName: "arrow.down")
//                    .font(.system(size: 60))
//                    .foregroundStyle(.thinMaterial)
//                    .symbolEffect(.wiggle)
//            }
//            .padding(.trailing, 18)
        }
        .zIndex(2)
        .padding(.bottom, 70)
    }
    
// MARK: - Tutorial Stage 3 (Job)
    @ViewBuilder
    func tutorialStage3() -> some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: UIScreen.main.bounds.width / 1.2, height: 200)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 2)
                    )
                
                VStack(spacing: 16) {
                    Text("Welcome to your job page! Here you clock into work, see your current role, salary and your progress towards a promotion.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 1)
                        .lineLimit(nil)
                    
                    Button(action: {
                        tutorialStage = 4
                    }) {
                        Text("Next")
                            .bold()
                            .padding(.vertical, 7)
                            .padding(.horizontal, 40)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 1.3, height: 180)
                .multilineTextAlignment(.center)
            }
            
//            HStack {
//                Spacer()
//                Image(systemName: "arrow.down")
//                    .font(.system(size: 60))
//                    .foregroundStyle(.thinMaterial)
//                    .symbolEffect(.wiggle)
//            }
//            .padding(.trailing, 67)
            HStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .font(.system(size: 60))
                    .foregroundStyle(.thinMaterial)
                    .symbolEffect(.wiggle)
            }
            .padding(.trailing, 34)
        }
        .zIndex(2)
        .padding(.bottom, 70)
    }
    
// MARK: - Tutorial Stage 4 (Goals)
    @ViewBuilder
    func tutorialStage4() -> some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: UIScreen.main.bounds.width / 1.2, height: 200)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 2)
                    )
                
                VStack(spacing: 16) {
                    Text("Welcome to your goals page! Here you can see your progression towards reaching the game's goals.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 1)
                        .lineLimit(nil)
                    
                    Button(action: {
                        tutorialStage = 5
                    }) {
                        Text("Next")
                            .bold()
                            .padding(.vertical, 7)
                            .padding(.horizontal, 40)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 1.3, height: 180)
                .multilineTextAlignment(.center)
            }
            
            HStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .font(.system(size: 60))
                    .foregroundStyle(.thinMaterial)
                    .symbolEffect(.wiggle)
            }
            .padding(.trailing, 18)
        }
        .zIndex(2)
        .padding(.bottom, 70)
    }
    
// MARK: - Tutorial Stage Finished
    @ViewBuilder
    func tutorialStageFinished() -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: UIScreen.main.bounds.width / 1.2, height: 200)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 2)
                    )
                
                VStack(spacing: 16) {
                    Text("You are now ready to start your journey! Good luck!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 1)
                        .lineLimit(nil)
                    
                    Button(action: {
                        tutorialStage = 6
                        completedTutorial = true
                    }) {
                        Text("Let's Go!")
                            .bold()
                            .padding(.vertical, 7)
                            .padding(.horizontal, 40)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 1.3, height: 180)
                .multilineTextAlignment(.center)
            }
        }
        .zIndex(2)
    }
}

#Preview {
    TutorialFlow(tutorialStage: 2, selectedTutorialTab: 2)
}
