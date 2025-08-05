//
//  Questions.swift
//  GoodCents
//
//  Created by GoodCents on 10/12/2024.
//

import Foundation

// MARK: -job question model
struct JobQuizQuestion: Identifiable {
    var id = UUID()
    let text: String
    let originalAnswers: [String]
    private(set) var answers: [String]
    private(set) var correctAnswerIndex: Int

    init(text: String, answers: [String], correctAnswerIndex: Int) {
        self.text = text
        self.originalAnswers = answers
        // Shuffle answers and adjust the correct answer index
        let shuffled = answers.enumerated().shuffled()
        self.answers = shuffled.map { $0.element }
        self.correctAnswerIndex = shuffled.firstIndex { $0.offset == correctAnswerIndex }!
    }
}

// MARK: - questions for job quiz
let JobQuizQuestions: [JobQuizQuestion] = [
    JobQuizQuestion(text: "What account is used for daily expenses?", answers: ["Savings", "Retirement", "Spending", "Term Deposit"], correctAnswerIndex: 2),
    JobQuizQuestion(text: "According to the 50/30/20 rule, what percentage of your income should be used for needs?", answers: ["50%", "30%", "20%", "10%"], correctAnswerIndex: 0),
    JobQuizQuestion(text: "What is the primary purpose of a savings account?", answers: ["To pay monthly bills", "To grow emergency funds", "To make stock investments", "To pay off loans"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is considered a liability?", answers: ["Savings account", "Mortgage loan", "Car value", "Monthly income"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is a budget?", answers: ["A plan for spending and saving money", "An account for retirement savings", "A type of tax refund", "An investment portfolio"], correctAnswerIndex: 0),
    JobQuizQuestion(text: "What is the purpose of an emergency fund?", answers: ["To invest in stocks", "To cover unexpected expenses", "To pay monthly rent", "To save for retirement"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What does APR stand for?", answers: ["Annual Percentage Rate", "Annual Payment Ratio", "Average Profit Return", "Accumulated Payment Reserve"], correctAnswerIndex: 0),
    JobQuizQuestion(text: "What is the first step in creating a budget?", answers: ["Track your income", "Calculate your monthly expenses", "Set financial goals", "Open a savings account"], correctAnswerIndex: 0),
    JobQuizQuestion(text: "What is the 50/30/20 rule used for?", answers: ["Tracking your diet", "Creating a personal budget", "Managing investments", "Saving for retirement"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What type of account is best for long-term savings?", answers: ["Checking account", "Savings account", "Certificate of deposit (CD)", "Retirement account"], correctAnswerIndex: 2),
    JobQuizQuestion(text: "What is compound interest?", answers: ["Interest earned on the principal only", "Interest earned on the principal and previously earned interest", "A penalty fee for late payments", "A tax on savings"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "Which is a good way to avoid unnecessary spending?", answers: ["Paying with cash", "Buying on impulse", "Using a credit card for every purchase", "Avoiding a budget"], correctAnswerIndex: 0),
    JobQuizQuestion(text: "What does a credit score measure?", answers: ["Your income level", "Your ability to repay loans", "Your spending habits", "Your tax payments"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "Why should you check your bank statements regularly?", answers: ["To see your credit score", "To check for errors or unauthorized transactions", "To apply for a loan", "To close your account"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is one advantage of using a debit card over a credit card?", answers: ["It helps build credit", "It avoids interest charges", "It offers cashback rewards", "It has a higher spending limit"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is a good rule of thumb for saving money?", answers: ["Save 10-15% of your income", "Save all your leftover money", "Only save when you get a bonus", "Save only for big purchases"], correctAnswerIndex: 0),
    JobQuizQuestion(text: "What is the purpose of a credit card limit?", answers: ["To encourage spending", "To set a maximum amount you can borrow", "To track your purchases", "To calculate your interest rate"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is the safest way to build credit?", answers: ["Max out your credit card", "Pay your credit card bills on time", "Open as many accounts as possible", "Use only cash for purchases"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What does 'living within your means' mean?", answers: ["Spending less than you earn", "Earning more than you spend", "Spending everything you earn", "Borrowing money to pay bills"], correctAnswerIndex: 0),
    JobQuizQuestion(text: "What is the benefit of setting financial goals?", answers: ["It allows you to avoid budgeting", "It keeps you focused and helps you prioritize spending", "It guarantees wealth", "It eliminates financial risks"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is an example of a variable expense?", answers: ["Utilities", "Car payment", "Gym membership", "Groceries"], correctAnswerIndex: 3),
    JobQuizQuestion(text: "Why is it important to have a good credit score?", answers: ["To qualify for higher salaries", "To get better loan and credit card terms", "To avoid taxes", "To avoid paying bills"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is one way to save on monthly expenses?", answers: ["Ignore your budget", "Shop around for better insurance rates", "Always eat out", "Use only cash"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "Which of these is an example of 'paying yourself first'?", answers: ["Investing in stocks", "Saving a portion of your income before spending", "Paying your rent on time", "Buying groceries"], correctAnswerIndex: 1),
    JobQuizQuestion(text: "What is the difference between a need and a want?", answers: ["A need is necessary for survival; a want is not", "A want is more expensive than a need", "A need is a one-time expense; a want is recurring", "A want is always a luxury item"], correctAnswerIndex: 0)
]
