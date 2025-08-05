//
//  LessonDetailView.swift
//  GoodCents
//
//  Created by GoodCents on 26/12/2024.
//

import SwiftUI
import SwiftData

struct LessonDetailView: View {
    @Query var completedLessons: [CompletedLessons]
    
    @State private var selectedAnswer: [Int: Int] = [:]
    @State private var answerSubmitted: Bool = false
    @State private var currentPageIndex: Int = 0
    @State private var showQuestions: Bool = false
    @State private var showLessonComplete: Bool = false
    @State private var outcomeRandomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.lessonPassColors)
    @State private var lessonRandomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.moneyThemeColors)
    @State private var showCloseAlert: Bool = false
    @State private var questionsCorrect: Int = 0
    
    @AppStorage("completedLessonThisWeek") private var completedLessonThisWeek: Bool = false
    
    let meshTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    let lesson: Lesson
    
    var body: some View {
        VStack {
            NavigationStack {
                ZStack {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: MeshGradientValues.points,
                        colors: lessonRandomColorSet
                    )
                    .ignoresSafeArea()
                    .opacity(0.8)
                    .onReceive(meshTimer) { _ in
                        withAnimation(.easeInOut(duration: 3)) {
                            lessonRandomColorSet = MeshGradientValues.randomColors(from: lessonRandomColorSet)
                        }
                    }
                    .zIndex(-1)
                    
                    VStack(alignment: .leading) {
                        if !showQuestions {
                            LessonPages()
                        } else {
                            LessonQuestions()
                        }
                    }
                }
                .animation(.easeInOut, value: showQuestions)
                .navigationTitle(lesson.title)
                .fullScreenCover(isPresented: $showLessonComplete) {
                    LessonQuizComplete(questionsCorrect: questionsCorrect)
                }
                .confirmationDialog("Are you sure you want to close?\nYour progress will be lost", isPresented: $showCloseAlert) {
                    Button("Close", role: .destructive) {
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to close?\nYour progress will be lost")
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showCloseAlert = true
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: showLessonComplete)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: -lesson pages view (content/learning material)
    @ViewBuilder
    func LessonPages() -> some View {
        VStack {
            if lesson.pages.indices.contains(currentPageIndex) {
                VStack {
                    Spacer()
                    Text(lesson.pages[currentPageIndex].content)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: geometry.size.width + 20, height: geometry.size.height + 20)
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            }
                        )
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            Spacer()
            
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 40)
                    .shadow(radius: 2)
                
                HStack {
                    Button(action: {
                        if currentPageIndex > 0 {
                            currentPageIndex -= 1
                        } else if currentPageIndex == 0 {
                            showCloseAlert = true
                        }
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                            .opacity(currentPageIndex == 0 ? 1 : 0)
                            .animation(.bouncy, value: currentPageIndex)
                        
                        Image(systemName: "arrow.left")
                            .font(.title2)
                    }
                    
                    Text("\(currentPageIndex + 1) / \(lesson.pages.count)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 5)
                    
                    Button(action: {
                        if currentPageIndex < lesson.pages.count - 1 {
                            currentPageIndex += 1
                        } else {
                            showQuestions = true
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.title2)
                        
                        Image(systemName: "questionmark.text.page")
                            .font(.title2)
                            .opacity(currentPageIndex == lesson.pages.count - 1 ? 1 : 0)
                            .animation(.bouncy, value: currentPageIndex)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 30)
        }
    }
    
// MARK: - lesson questions view
    @ViewBuilder
    func LessonQuestions() -> some View {
        ScrollView {
            ForEach(lesson.questions, id: \.id) { question in
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.question)
                        .font(.title3)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<question.answers.count, id: \.self) { index in
                            Button(action: {
                                if !answerSubmitted {
                                    selectedAnswer[question.id] = index
                                }
                            }) {
                                HStack {
                                    Image(systemName: selectedAnswer[question.id] == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedAnswer[question.id] == index ? .green : .gray)
                                    
                                    Text(question.answers[index].answer)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 5)
                                .padding(.vertical)
                                .background(Color.gray.opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .disabled(answerSubmitted)
                            
                            if answerSubmitted && question.answers[index].isCorrect {
                                Text("Correct")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                            } else if answerSubmitted && question.answers[index].isCorrect == false && selectedAnswer[question.id] == index {
                                Text("Incorrect")
                                    .font(.headline)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
                .padding(.horizontal, 5)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.3)
                        .scaleEffect(phase.isIdentity ? 1 : 0.90)
                        .blur(radius: phase.isIdentity ? 0 : 2)
                }
                .padding(.vertical, 10)
            }
        }
        
        Button(action: {
            if !answerSubmitted {
                questionsCorrect = lesson.questions.filter { question in
                    guard let selectedIndex = selectedAnswer[question.id] else { return false }
                    return question.answers[selectedIndex].isCorrect
                }.count
                answerSubmitted = true
            } else {
                saveCompletedLesson()
                showLessonComplete = true
            }
        }) {
            Text(answerSubmitted ? "Next" : "Submit")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, maxHeight: 40)
        }
        .disabled(selectedAnswer.count != lesson.questions.count)
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 7)
    }
    
    // MARK: -lesson quiz complete view
    @ViewBuilder
    func LessonQuizComplete(questionsCorrect: Int) -> some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.white.opacity(0.2))
            
            MeshGradient(
                width: 3,
                height: 3,
                points: MeshGradientValues.points,
                colors: outcomeRandomColorSet
            )
            .ignoresSafeArea()
            .opacity(0.8)
            .onAppear {
                fetchQuizColors(questionsCorrect: questionsCorrect, totalQuestions: lesson.questions.count)
            }
            .onReceive(meshTimer) { _ in
                withAnimation(.easeInOut(duration: 3)) {
                    outcomeRandomColorSet = MeshGradientValues.randomColors(from: outcomeRandomColorSet)
                }
            }
            .zIndex(-1)
            
            VStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20.0)
                        .fill(.black.opacity(0.1))
                        .frame(width: 350, height: 250)
                        .shadow(radius: 5)
                    
                    VStack {
                        Text("Congratulations!")
                            .font(.system(size: 40))
                            .bold()
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Text("You have completed the lesson!\nYou got \(questionsCorrect) / \(lesson.questions.count) questions correct.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.8))
                        
                        if questionsCorrect < lesson.questions.count {
                            Text("Try again to get a better score!")
                                .font(.headline)
                                .padding(.top, 5)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    saveCompletedLesson()
                    completedLessonThisWeek = true
                    dismiss()
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
    
    // MARK: - fetch quiz colors based on quiz results
    func fetchQuizColors(questionsCorrect: Int, totalQuestions: Int) {
        let fractionCorrect = Double(questionsCorrect) / Double(totalQuestions)
        
        if fractionCorrect == 1.0 {
            outcomeRandomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.lessonPassColors) // green
        } else if fractionCorrect >= 2.0 / 3.0 {
            outcomeRandomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.lessonHalfPassColors) // yellow
        } else {
            outcomeRandomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.lessonFailColors) // red
        }
    }


    // MARK: - helper for saving completed lesson
    private func saveCompletedLesson() {
        if let existingLesson = completedLessons.first(where: { $0.lessonId == lesson.id }) {
            // Lesson already exists
            if questionsCorrect == lesson.questions.count && !existingLesson.allQuestionsCorrect {
                // Update the property directly
                existingLesson.allQuestionsCorrect = true
            }
        } else {
            // Lesson doesn't exist, create a new one
            let gotAllQuestionsCorrect = questionsCorrect == lesson.questions.count
            let newLesson = CompletedLessons(lessonId: lesson.id, lessonTitle: lesson.title, allQuestionsCorrect: gotAllQuestionsCorrect)
            
            modelContext.insert(newLesson)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save completed lesson: \(error.localizedDescription)")
        }
    }
}
