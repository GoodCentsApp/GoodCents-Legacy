//
//  SwiftDataModels.swift
//  GoodCents
//
//  Created by GoodCents on 11/20/24.
//

import SwiftData
import Foundation


// MARK: -Player Model
@Model
class Player {
    var name: String
    var weeklyExpenses: Double
    var spendingAccount: Double
    var savings: Double
    var retirementSavings: Double
    var job: Job?
    var wealthClass: WealthClasses {
        calculatePlayersWealthClass(spendingAccount)
    }

    // computes total money from all accounts
    var totalMoney: Double {
        spendingAccount + savings + retirementSavings
    }
    
    var weeklyIncome: Double {
        job?.jobIncome ?? 0
    }
    
    func balance(for account: PlayerAccount) -> Double {
        switch account {
        case .spendingAccount:
            return spendingAccount
        case .savings:
            return savings
        case .retirementSavings:
            return retirementSavings
        }
    }
    
    // inits the variables
    init(
        spendingAccount: Double = 200.00,
        savings: Double = 500.00,
        retirementSavings: Double = 250.00,
        name: String = "",
        job: Job? = nil
    ) {
        self.name = name
        self.spendingAccount = spendingAccount
        self.savings = savings
        self.retirementSavings = retirementSavings
        self.job = job
        self.weeklyExpenses = 0
        self.weeklyExpenses = generateWeeklyExpenses(weeklyIncome: weeklyIncome)
    }
}

enum PlayerAccount: String, CaseIterable, Codable {
    case spendingAccount = "Spending"
    case savings = "Savings"
    case retirementSavings = "Retirement"
    
    var underfundedThreshold: Double {
        switch self {
        case .spendingAccount: return 200
        case .savings: return 1000
        case .retirementSavings: return 500
        }
    }
}

// MARK: -Job Model
@Model
class Job {
    var jobPromotionProgress: Int
    var jobPromotionLevel: Int {
        switch jobPromotionProgress {
        case 0..<25:
            return 0
        case 25..<75:
            return 1
        case 75..<150:
            return 2
        case 150..<250:
            return 3
        case 250..<350:
            return 4
        case 350...:
            return 5
        default:
            return 0
        }
    }
    
    // calculate job title based on job promotion level
    var jobTitle: String {
        switch jobPromotionLevel {
        case 1:
            return "Apprentice"
        case 2:
            return "Professional"
        case 3:
            return "Expert"
        case 4:
            return "Master"
        case 5:
            return "Legend"
        default:
            return "Newbie"
        }
    }
    
    // calculate job promotion goal based on job promotion level
    var jobPromotionGoal: Int {
        switch jobPromotionLevel {
        case 1:
            return 75
        case 2:
            return 150
        case 3:
            return 250
        case 4:
            return 349
        case 5:
            return 350
        default:
            return 25
        }
    }
    
    // calculate job income based on job promotion
    var jobIncome: Double {
        switch jobPromotionLevel {
        case 1:
            return 1094.43
        case 2:
            return 1175.73
        case 3:
            return 1245.89
        case 4:
            return 1325.13
        case 5:
            return 1400.24
        default:
            return 950.24
        }
    }
    
    init(
        jobPromotionProgress: Int
    ) {
        self.jobPromotionProgress = min(jobPromotionProgress, 350)
    }
}

// MARK: -Transactions Model
@Model
class Transactions {
    var account: String
    var name: String
    var value: Double
    var date: Date
    var balanceAfterTransaction: Double
    
    // save transaction to the model
    static func saveTransaction(
        account: String,
        name: String,
        value: Double,
        balanceAfterTransaction: Double,
        context: ModelContext
    ) {
        let transaction = Transactions(
            account: account,
            name: name,
            value: value,
            date: Date.now,
            balanceAfterTransaction: balanceAfterTransaction
        )
        context.insert(transaction)
    }

    init(
        account : String,
        name: String,
        value: Double,
        date: Date = Date.now,
        balanceAfterTransaction: Double
    ) {
        self.account = account
        self.name = name
        self.value = value
        self.date = date
        self.balanceAfterTransaction = balanceAfterTransaction
    }
}

// MARK: -Time Model
@Model
class Time {
    var week: Int
    var month: Int
    var year: Int
    
    init(week: Int = 1, month: Int, year: Int) {
        self.week = week
        self.month = month
        self.year = year
    }
}

// MARK: -OwnedItems Model
@Model
class OwnedItems {
    var itemName: String
    var itemPrice: Double
    var itemIcon: String
    var itemQuantity: Int
    var itemValue: Double
    var itemIsSellable: Bool

    init(
        itemName: String,
        itemPrice: Double,
        itemIcon: String,
        itemIsSellable: Bool,
        itemQuantity: Int,
        itemValue: Double
    ) {
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemIcon = itemIcon
        self.itemQuantity = itemQuantity
        self.itemIsSellable = itemIsSellable
        self.itemValue = itemValue
    }
}

// MARK: -CompletedLessons Model
@Model
class CompletedLessons {
    var lessonId: Int
    var lessonTitle: String
    var allQuestionsCorrect: Bool
    
    static func deleteAll(from context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CompletedLessons>()
        if let lessons = try? context.fetch(fetchDescriptor) {
            for lesson in lessons {
                context.delete(lesson)
            }
        }
        try? context.save()
    }
    
    init(
        lessonId: Int,
        lessonTitle: String,
        allQuestionsCorrect: Bool
    ) {
        self.lessonId = lessonId
        self.lessonTitle = lessonTitle
        self.allQuestionsCorrect = allQuestionsCorrect
    }
}
