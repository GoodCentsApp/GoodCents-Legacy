//
//  LessonMainView.swift
//  GoodCents
//
//  Created by GoodCents on 23/12/2024.
//

import SwiftUI
import SwiftData
import Confetti

struct LessonMainView: View {
    @Query var completedLessons: [CompletedLessons]
    @State private var showLessonCover: Bool = false
    @State private var selectedLesson: Lesson? = nil
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var lessons: [LessonSection] {
        return Bundle.main.decode([LessonSection].self, from: "education.json")
    }
    
    var allLessons: [Lesson] {
        lessons.flatMap { $0.lessons }
    }

    // function to check is a lesson should be enabled
    /// i hate how long it took for me to figure this out >.<
    private func isLessonEnabled(_ lesson: Lesson) -> Bool {
        // check if a lesson is complete
        if let completedLesson = completedLessons.first(where: { $0.lessonId == lesson.id }) {
            // still enable the lesson if it was completed but not all questions were correct
            if !completedLesson.allQuestionsCorrect {
                return true
            } else {
                // if the lesson is completed **and** all questions were correct, disable it
                return false
            }
        }
        
        // get the index of the current lesson from allLessons
        guard let currentIndex = allLessons.firstIndex(where: { $0.id == lesson.id }) else {
            return false
        }
        
        // **always** enable the very first lesson
        if currentIndex == 0 {
            return true
        }
        
        // make sure the lessons before the current one is disabled
        for previousLesson in allLessons[0..<currentIndex] {
            if !completedLessons.contains(where: { $0.lessonId == previousLesson.id }) {
                return false
            }
        }
        
        // otherwise enable the lesson
        return true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(lessons) { section in
                        Section(section.title) {
                            ForEach(section.lessons) { lesson in
                                Button(action: {
                                    selectedLesson = lesson
                                    showLessonCover = true
                                    
                                    //                                let newLesson = CompletedLessons(lessonId: lesson.id, lessonTitle: lesson.title)
                                    //                                modelContext.insert(newLesson)
                                }) {
                                    LessonListItem(
                                        title: lesson.title,
                                        description: lesson.description,
                                        isEnabled: isLessonEnabled(lesson)
                                    )
                                }
                                .disabled(!isLessonEnabled(lesson))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lessons")
            .fullScreenCover(isPresented: Binding(
                get: { showLessonCover && selectedLesson != nil },
                set: { newValue in
                    if !newValue {
                        showLessonCover = false
                        selectedLesson = nil
                    }
                }
            )) {
                if let lesson = selectedLesson {
                    LessonDetailView(lesson: lesson)
                } else {
                    Text("Error: Lesson not found.")
                }
            }
        }
    }
    
    @ViewBuilder
    func LessonListItem(title: String, description: String, isEnabled: Bool) -> some View {
        let lessonComplete = completedLessons.contains { $0.lessonTitle == title && $0.allQuestionsCorrect == true }
        let lessonCompleteAnswersWrong = completedLessons.contains { $0.lessonTitle == title && $0.allQuestionsCorrect == false }
        
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .opacity(isEnabled ? 1.0 : 0.6)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .opacity(isEnabled ? 1.0 : 0.6)
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            if lessonComplete {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.green)
            } else if lessonCompleteAnswersWrong {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.orange)
                    .symbolEffect(.bounce, options: .repeat(2))
            } else if !isEnabled {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.gray)
            }
            
            if isEnabled || lessonCompleteAnswersWrong {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.trailing, 7)
                    .symbolEffect(.wiggle)
            }
        }
    }
}

#Preview {
    LessonMainView()
}
