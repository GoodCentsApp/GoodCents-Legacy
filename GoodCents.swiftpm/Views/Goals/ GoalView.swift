//
//  GoalView.swift
//  GoodCents
//
//  Created by GoodCents on 23/12/2024.
//

import SwiftUI
import SwiftData
import Confetti

struct GoalView: View {
    // Needed for the actual goal view
    @Query var player: [Player]
    @Query var job: [Job]
    @Query var completedLessons: [CompletedLessons]
    
    @AppStorage("completedGoals") var completedGoals: Int = 0
    @State var showConfetti: Bool = false
    @State var showConfirmation: Bool = false
    
    struct GoalData {
        let title: String
        let description: String
        let progress: Double
    }
    
    var goals: [GoalData] {
        [
            GoalData(
                title: "Ascend the Ranks!",
                description: "Reach Legend promotion at Apple Seed Orchards.",
                progress: Double(job.first?.jobPromotionLevel ?? 0) / 5
            ),
            GoalData(
                title: "Save for the Future!",
                description: "Save $10,000 in your Retirement Savings account.",
                progress: (player.first?.retirementSavings ?? 0) / 10000
            ),
            GoalData(
                title: "Become a Money Genius!",
                description: "Complete all lessons in the lessons tab.",
                progress: Double(completedLessons.count) / 12
            )
        ]
    }
    
    // Needed for the reset function
    @Query var time: [Time]
    @Query var transaction: [Transactions]
    @Query var ownedItems: [OwnedItems]
    @AppStorage("withdrawnThisMonth") var withdrawnThisMonth: Bool = false
    @AppStorage("doneThisWeeksQuiz") var doneThisWeeksQuiz: Bool = false
    @AppStorage("doneThisWeeksInteractiveEvent") var doneThisWeeksInteractiveEvent: Bool = false
    @AppStorage("completedLessonThisWeek") var completedLessonThisWeek: Bool = false
    @AppStorage("completedTutorial") var completedTutorial: Bool = false
    @AppStorage("completedWelcome") var completedWelcome: Bool = false
    @AppStorage("currentPage") var currentPage: Int = 0
    @AppStorage("isInitialised") private var isInitialised = false
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(goals, id: \.title) { goal in
                        GoalItem(
                            title: goal.title,
                            description: goal.description,
                            progress: goal.progress
                        )
                    }
                    
                    HStack {
                        ZStack {
                            Image(systemName: "trophy.circle")
                                .frame(width: 150, height: 70)
                                .font(.system(size: 112))
                                .foregroundStyle(completedGoals == 3 ? .blue : .primary.opacity(0.2))
                            
                            Circle()
                                .trim(from: 0, to: Double(completedGoals) / 3)
                                .stroke(
                                    Color.blue,
                                    style: StrokeStyle(
                                        lineWidth: 9,
                                        lineCap: .round
                                    )
                                )
                                .frame(width: 150, height: 102)
                                .rotationEffect(.degrees(-90))
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Complete all goals")
                                .font(.title2)
                                .bold()
                            
                            Text("Complete all the goals to win the game!")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineLimit(nil)
                        }
                    }
                    Spacer()
                    
                    if completedGoals == 3 {
                        HStack {
                            Spacer()
                            
                            Button(role: .destructive, action: {
                                showConfirmation = true
                            }) {
                                Text("Reset Game")
                                    .font(.headline)
                                    .frame(width: 150, height: 20)
                            }
                            .sensoryFeedback(.selection, trigger: showConfirmation)
                            .buttonStyle(.borderedProminent)
                            
                            Spacer()
                        }
                        .padding(.bottom, 10 )
                    }
                }
                .padding(.trailing)
                .padding(.top, 10)
                .navigationTitle("Goals")
                .onAppear(perform: checkGoalProgress)
                
                if showConfetti {
                    ConfettiSpam(showConfetti: $showConfetti, emissionDuration: 3.0)
                }
            }
        }
        .onAppear {
            if completedGoals == 3 {
                showConfetti = true
            }
        }
        .onDisappear {
            showConfetti = false
        }
        .confirmationDialog("Are you sure you want to reset your game?", isPresented: $showConfirmation) {
            Button("Reset Game", role: .destructive) {
                clearAllData(
                    player: player,
                    job: job,
                    time: time,
                    transactions: transaction,
                    ownedItems: ownedItems,
                    completedLessons: completedLessons,
                    withdrawnThisMonth: &withdrawnThisMonth,
                    doneThisWeeksQuiz: &doneThisWeeksQuiz,
                    doneThisWeeksInteractiveEvent: &doneThisWeeksInteractiveEvent,
                    completedLessonThisWeek: &completedLessonThisWeek,
                    completedTutorial: &completedTutorial,
                    completedWelcome: &completedWelcome,
                    currentPage: &currentPage,
                    isInitialised: &isInitialised,
                    modelContext: modelContext
                )
            }
        } message: {
            Text("This will reset your game and you will lose all progress.")
        }
    }

// MARK: - goal item (so like the circle and text)
    @ViewBuilder
    func GoalItem(title: String, description: String, progress: Double, lineWidth: CGFloat = 11) -> some View {
        HStack {
            ZStack {
                CircularProgressView(progress: progress, lineWidth: lineWidth)
                    .frame(width: 150, height: 100)
                
                if progress >= 1.0 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                        .bold()
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.blue)
                }
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    func checkGoalProgress() {
        let completedCount = goals.filter { $0.progress >= 1.0 }.count
        completedGoals = completedCount
    }
}

#Preview {
    GoalView()
}
