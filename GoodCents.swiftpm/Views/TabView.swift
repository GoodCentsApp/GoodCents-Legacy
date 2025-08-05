//
//  TabView.swift
//  GoodCents
//
//  Created by GoodCents on 11/20/24.
//

import SwiftUI
import SwiftData

struct TabMainView: View {
    @Query var players: [Player]
    @Query var completedLessons: [CompletedLessons]
    @State private var showTransferSheet = false
    @AppStorage("completedWelcome") private var completedWelcome = false
    @AppStorage("completedLessonThisWeek") private var completedEventThisWeek = false
    
    // Tutorial Flags
    @AppStorage("tutorialStage") var tutorialStage: Int = 1
    @AppStorage("completedTutorial") private var completedTutorial: Bool = false
    @AppStorage("selectedTutorialTab") var selectedTutorialTab: Int = 0 // (for future me) selectedTab is to keep track of the currently enabled Tab in the tutorial Tab Bar
    
    var body: some View {
        VStack {
            if completedTutorial {
                NormalTabView()
            } else {
                TutorialFlow(tutorialStage: tutorialStage, selectedTutorialTab: selectedTutorialTab)
            }
        }
        .fullScreenCover(isPresented: .constant(!completedWelcome)) {
            WelcomeView()
                .onDisappear {
                    completedWelcome = true
                }
        }
    }

// MARK: - normal tab view (tutorial complete)
    @ViewBuilder
    func NormalTabView() -> some View {
        TabView {
            Tab("Home", systemImage: "house") {
                Home()
            }
            
            if completedEventThisWeek || completedLessons.count >= 12 {
                Tab("Lessons", systemImage: "graduationcap.fill") {
                    LessonMainView()
                }
            } else {
                Tab("Lessons", systemImage: "graduationcap.fill") {
                    LessonMainView()
                }
                .badge("!")
            }
            
            Tab("Job", systemImage: "suitcase") {
                JobOverview()
            }
            
            Tab("Goals", systemImage: "circle.dashed") {
                GoalView()
            }
        }
    }
}

#Preview {
    TabMainView()
}
