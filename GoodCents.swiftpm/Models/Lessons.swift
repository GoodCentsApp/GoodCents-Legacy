//
//  Lessons.swift
//  GoodCents
//
//  Created by GoodCents on 23/12/2024.
//

import Foundation


// struct for the lesson **sections**
struct LessonSection: Codable, Identifiable {
    let id: Int
    let title: String
    let lessons: [Lesson]
}

// struct for the lesson **items**
struct Lesson: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let pages: [Page]
    let questions: [Question]
}

// struct for the lesson item **pages**
struct Page: Codable, Identifiable {
    let id: Int
    let title: String
    let content: String
}

// struct for the lesson item **questions**
struct Question: Codable, Identifiable {
    let id: Int
    let question: String
    let answers: [Answer]
}

// struct for the lesson item question **answers**
struct Answer: Codable, Identifiable {
    let id: Int
    let answer: String
    let isCorrect: Bool
}
