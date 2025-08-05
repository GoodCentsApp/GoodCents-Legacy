//
//  JobQuiz.swift
//  GoodCents
//
//  Created by GoodCents on 10/12/2024.
//

import SwiftUI
import SwiftData

// MARK: - Quiz Struct
struct JobQuiz: View {
    @Query var job: [Job]
    
    let questions: [JobQuizQuestion] = JobQuizQuestions
    @State private var selectedAnswers: [UUID: Int] = [:]
    @State private var currentQuestionIndex: Int = 0
    @State private var correctQuestions: Int = 0
    @State private var isAnswerSubmitted: Bool = false
    @State private var randomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.quizColors)
    @State private var shuffledQuestions: [JobQuizQuestion] = []
    
    @AppStorage("doneThisWeeksQuiz") var doneThisWeeksQuiz: Bool = false
    
    let meshTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        ZStack {
            if currentQuestionIndex < shuffledQuestions.count && currentQuestionIndex < 3 {
                QuizSystemView()
            } else {
                QuizFinished()
            }
                
            QuizBgMeshGradient()
        }
        .onAppear {
            shuffledQuestions = JobQuizQuestions.shuffled()
        }

    }
    
// MARK: -Quiz System
    @ViewBuilder
    func QuizSystemView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            let question = shuffledQuestions[currentQuestionIndex]
            
            VStack(alignment: .leading, spacing: 10) {
                Text(question.text)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                ForEach(0..<question.answers.count, id: \.self) { index in
                    Button(action: {
                        selectedAnswers[question.id] = index
                    }) {
                        HStack {
                            Image(systemName: selectedAnswers[question.id] == index ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedAnswers[question.id] == index ? .green : .white)
                            Text(question.answers[index])
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(8)
                    }
                    .disabled(isAnswerSubmitted)
                    
                    if isAnswerSubmitted && index == question.correctAnswerIndex {
                        Text("Correct")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    
                    if isAnswerSubmitted && index == selectedAnswers[question.id] && index != question.correctAnswerIndex {
                        Text("Incorrect")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .padding(0)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(12)
            .shadow(radius: 5)
            
            Spacer()
            
            Button(action: {
                if isAnswerSubmitted {
                    isAnswerCorrect(for: question)
                    currentQuestionIndex += 1
                    isAnswerSubmitted = false
                } else {
                    isAnswerSubmitted = true
                }
            }) {
                Text(isAnswerSubmitted ? "Next" : "Submit")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .cornerRadius(10)
            }
            .padding(.top)
            .buttonStyle(.borderedProminent)
            .disabled(selectedAnswers[question.id] == nil)
        }
        .padding()
    }

    
// MARK: -Quiz Finished Screen
    @ViewBuilder
    func QuizFinished() -> some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.white.opacity(0.2))
            
            VStack {
                Spacer()
                
                Text(endOfQuizText())
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white.opacity(0.6))
                
                Text("You got \(correctQuestions) out of 3 questions correct.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))
                
                if correctQuestions != 3 {
                    Text("Visit the lessons tab to improve your knowledge!")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                    awardPromotionPoints()
                    doneThisWeeksQuiz = true
                }) {
                    Text("Close")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
    
// MARK: -Quiz Background Mesh Gradient
    @ViewBuilder
    func QuizBgMeshGradient() -> some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: MeshGradientValues.points,
            colors: randomColorSet
        )
        .ignoresSafeArea()
        .opacity(0.8)
        .onReceive(meshTimer) { _ in
            withAnimation(.easeInOut(duration: 3)) {
                randomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.quizColors)
            }
        }
        .zIndex(-1)
    }
    
// MARK: -Is Answer Correct
    func isAnswerCorrect(for question: JobQuizQuestion) {
        let selectedIndex = selectedAnswers[question.id]
        if question.correctAnswerIndex == selectedIndex {
            correctQuestions += 1
        }
    }
    
// MARK: -Award Promotion Points
    func awardPromotionPoints() {
        if let job = job.first {
            let promotionModifier = Double(job.jobPromotionLevel) * 0.2
            
            if correctQuestions == 1 {
                job.jobPromotionProgress += 5 + Int(ceil(promotionModifier))
            } else if correctQuestions == 2 {
                job.jobPromotionProgress += 10 + Int(ceil(promotionModifier))
            } else if correctQuestions == 3 {
                job.jobPromotionProgress += 15 + Int(ceil(promotionModifier))
            }
            
            if job.jobPromotionProgress > 350 {
                job.jobPromotionProgress = 350
            }

            try? modelContext.save()
        }
    }
// MARK: -End of Quiz Text
    func endOfQuizText() -> String {
        if correctQuestions == 0 {
            return "Better Luck Next Time!"
        } else if correctQuestions == 1 {
            return "Good Job!"
        } else if correctQuestions == 2 {
            return "Great Job!"
        } else {
            return "Amazing Job!"
        }
    }
}

#Preview {
    JobQuiz()
}
