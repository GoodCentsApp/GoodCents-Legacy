//
//  Functions.swift
//  GoodCents
//
//  Created by GoodCents on 04/02/2025.
//

import Foundation
import SwiftData

func sellItem(item: OwnedItems, player: Player, modelContext: ModelContext) {
    // double check the item is sellable
    guard item.itemIsSellable else { return }
    // double check the item actually has a valid quantity
    guard item.itemQuantity > 0 else { return }
    
    
    // set some variables, shortcut for item price, add sellprice to spending account and set the balance after the transaction (for the transaction history)
    let sellPrice = item.itemValue
    player.spendingAccount += sellPrice
    let balanceAfterTransaction = player.spendingAccount
    
    // remove the item from the player's inventory
    item.itemQuantity -= 1
    
    // if there is none left then just delete the item
    if item.itemQuantity == 0 {
        modelContext.delete(item)
    }
    
    // save the transaction
    Transactions.saveTransaction(
        account: "Everyday Spending",
        name: "Sold \(item.itemName)",
        value: sellPrice,
        balanceAfterTransaction: balanceAfterTransaction,
        context: modelContext
    )
    
    try? modelContext.save()
}

// generate weekly expenses
func generateWeeklyExpenses(weeklyIncome: Double) -> Double {
    let lowerBound = max(0, weeklyIncome - 80)
    let upperBound = weeklyIncome + 40
    return Double.random(in: lowerBound...upperBound)
}

func clearAllData(
    player: [Player],
    job: [Job],
    time: [Time],
    transactions: [Transactions],
    ownedItems: [OwnedItems],
    completedLessons: [CompletedLessons],
    withdrawnThisMonth: inout Bool,
    doneThisWeeksQuiz: inout Bool,
    doneThisWeeksInteractiveEvent: inout Bool,
    completedLessonThisWeek: inout Bool,
    completedTutorial: inout Bool,
    completedWelcome: inout Bool,
    currentPage: inout Int,
    isInitialised: inout Bool,
    modelContext: ModelContext
) {
    // Clear all queries
    for player in player {
        modelContext.delete(player)
    }
    for job in job {
        modelContext.delete(job)
    }
    for time in time {
        modelContext.delete(time)
    }
    for transaction in transactions {
        modelContext.delete(transaction)
    }
    for ownedItem in ownedItems {
        modelContext.delete(ownedItem)
    }
    for completedLesson in completedLessons {
        modelContext.delete(completedLesson)
    }
    
    // Clear all AppStorage variables
    withdrawnThisMonth = false
    doneThisWeeksQuiz = false
    doneThisWeeksInteractiveEvent = false
    completedLessonThisWeek = false
    completedTutorial = false
    completedWelcome = false
    currentPage = 0
    isInitialised = false
    
    try? modelContext.save()
}
