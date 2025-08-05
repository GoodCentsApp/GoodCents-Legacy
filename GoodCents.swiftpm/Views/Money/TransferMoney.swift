//
//  TransferMoney.swift
//  GoodCents
//
//  Created by GoodCents on 11/20/24.
//

import SwiftUI
import SwiftData

struct TransferMoney: View {
    var player: Player
    
    @Binding var sourceAccount: PlayerAccount
    @Binding var destinationAccount: PlayerAccount
    @Binding var transferAmount: Double
    @Binding var errorMessage: String?
    @Binding var successMessage: String?
    
    @AppStorage("withdrawnThisMonth") var withdrawnThisMonth: Bool = false
    
    @FocusState private var isFocused: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        Picker("Source Account", selection: $sourceAccount) {
            ForEach(PlayerAccount.allCases.filter { $0 != .retirementSavings }, id: \.self) { account in
                Text(account.rawValue)
            }
        }
        
        Picker("Destination Account", selection: $destinationAccount) {
            ForEach(PlayerAccount.allCases, id: \.self) { account in
                Text(account.rawValue)
            }
        }
        
        TextField(
            isFocused ? "" : "Transfer Amount",
            value: isFocused ? $transferAmount : Binding(
                get: { transferAmount },
                set: { transferAmount = $0 }
            ),
            format: .currency(code: Locale.current.currency?.identifier ?? "USD")
        )
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Dismiss") {
                    isFocused = false
                }
            }
        }
        
        .keyboardType(.decimalPad)
        .focused($isFocused)
        .onChange(of: isFocused) {
            if !isFocused && transferAmount == nil {
                transferAmount = 0.00
            }
        }
        
        Button(action: {
            transferFunds(
                to: destinationAccount,
                from: sourceAccount,
                transferAmount: transferAmount,
                player: player,
                modelContext: modelContext,
                errorMessage: &errorMessage,
                successMessage: &successMessage,
                withdrawnThisMonth: &withdrawnThisMonth
            )
            transferAmount = 0.00
            isFocused = false
        }) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14))
                
                Text("Transfer")
            }
        }
        
        if let errorMessage = errorMessage {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        
        if let successMessage = successMessage {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                
                Text(successMessage)
                    .foregroundStyle(.green)
            }
        }
    }
}

// MARK: - Transfer Funds
func transferFunds(to destinationAccount: PlayerAccount,
                   from sourceAccount: PlayerAccount,
                   transferAmount: Double,
                   player: Player,
                   modelContext: ModelContext,
                   errorMessage: inout String?,
                   successMessage: inout String?,
                   withdrawnThisMonth: inout Bool) {
    // this validates amount in account
    guard transferAmount > 0 else {
        errorMessage = "Please enter a valid amount."
        return
    }
    
    // checks that accounts aren't the same
    guard sourceAccount != destinationAccount else {
        errorMessage = "Source and destination accounts must be different."
        return
    }
    
    switch sourceAccount {
    // transfer logic from spending account
    case .spendingAccount:
        guard player.spendingAccount >= transferAmount else {
            errorMessage = "Insufficient funds in Spending Account."
            return
        }
        player.spendingAccount -= transferAmount
        let balanceAfterTransaction = player.spendingAccount

        Transactions.saveTransaction(
            account: "Everyday Spending",
            name: "Transfer to \(destinationAccount.rawValue)",
            value: -transferAmount,
            balanceAfterTransaction: Double(balanceAfterTransaction),
            context: modelContext
        )

        
    // transfer logic from savings account
    case .savings:
        guard player.savings >= transferAmount else {
            errorMessage = "Insufficient funds in Savings."
            return
        }
        player.savings -= transferAmount
        let balanceAfterTransaction = player.savings
        withdrawnThisMonth = true
        
        Transactions.saveTransaction(
            account: "Savings",
            name: "Transfer to \(destinationAccount.rawValue)",
            value: -transferAmount,
            balanceAfterTransaction: Double(balanceAfterTransaction),
            context: modelContext
        )
        
    // transfer logic from retirement savings account (this isn't ever used tho just there so no errors are caused)
    case .retirementSavings:
        guard player.retirementSavings >= transferAmount else {
            errorMessage = "Insufficient funds in Retirement Savings."
            return
        }
        player.retirementSavings -= transferAmount
        let balanceAfterTransaction = player.retirementSavings
        
        Transactions.saveTransaction(
            account: "Retirement Savings",
            name: "Transfer to \(destinationAccount.rawValue)",
            value: -transferAmount,
            balanceAfterTransaction: Double(balanceAfterTransaction),
            context: modelContext
        )
    }
    
    // transfers the money to the destination account
    switch destinationAccount {
    case .spendingAccount:
        player.spendingAccount += transferAmount
        let balanceAfterTransaction = player.spendingAccount
        
        Transactions.saveTransaction(
            account: "Everyday Spending",
            name: "Transfer from \(sourceAccount.rawValue)",
            value: transferAmount,
            balanceAfterTransaction: Double(balanceAfterTransaction),
            context: modelContext
        )
    case .savings:
        player.savings += transferAmount
        let balanceAfterTransaction = player.savings
        
        Transactions.saveTransaction(
            account: "Savings",
            name: "Transfer from \(sourceAccount.rawValue)",
            value: transferAmount,
            balanceAfterTransaction: Double(balanceAfterTransaction),
            context: modelContext
        )
    case .retirementSavings:
        player.retirementSavings += transferAmount
        let balanceAfterTransaction = player.retirementSavings
        
        Transactions.saveTransaction(
            account: "Retirement Savings",
            name: "Transfer from \(sourceAccount.rawValue)",
            value: transferAmount,
            balanceAfterTransaction: Double(balanceAfterTransaction),
            context: modelContext
        )
    }
    
    // error/success handling
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    if let formattedAmount = formatter.string(from: NSNumber(value: transferAmount)) {
        successMessage = "Successfully transferred \(formattedAmount) to \(destinationAccount.rawValue)."
    } else {
        successMessage = "Successfully transferred \(transferAmount) to \(destinationAccount.rawValue)."
    }
    errorMessage = nil
}
