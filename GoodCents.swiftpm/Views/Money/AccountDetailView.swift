//
//  AccountView.swift
//  GoodCents
//
//  Created by GoodCents on 11/20/24.
//

import SwiftUI
import SwiftData

// MARK: -AccountView
struct AccountView: View {
    @Query var players: [Player]
    @Query var transactions: [Transactions]
    
    var accountName: String
    var accountValue: Double
    var isAccount: Bool
    
    @State private var showTransactionInfo: Bool = false
    @State private var selectedTransaction: Transactions?
    @State private var selectedView: ViewOptions = .Transactions
    
    @AppStorage("withdrawnThisMonth") var withdrawnThisMonth: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.gray.opacity(0.1))
                        .frame(height: 150)
                    
                    VStack {
                        Text(accountName)
                            .font(.title)
                            .bold()
                        
                        Text(accountValue, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                }
                
                if isAccount && accountName != "Everyday Spending" {
                    Picker("View", selection: $selectedView) {
                        ForEach(ViewOptions.allCases, id: \.self) { option in
                            Text(option.displayName)
                                .tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                 
                if isAccount {
                    if selectedView == .Transactions {
                        Text("Transactions")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .bold()
                        
                        accountTransactions()
                    } else if selectedView == .AccountDetails {
                        Text("Account Details")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .bold()
                        
                        accountDetails()
                    }
                } else if accountName == "Weekly Expenses" {
                    weeklyExpensesTransactions()
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
    
// MARK: -TransactionItem
    @ViewBuilder
    func TransactionItem(
        transaction: Transactions
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.secondary.opacity(0.1))
                .frame(height: selectedTransaction?.id == transaction.id ? 110 : 50)
            
            VStack {
                HStack {
                    Text(transaction.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(transaction.value >= 0 ? "+" : "-")\(abs(transaction.value), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .frame(width: 100, alignment: .trailing)
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(selectedTransaction?.id == transaction.id ? 90 : 0))
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.trailing, 7)
                }
                .padding(.horizontal)
                
                if selectedTransaction?.id == transaction.id {
                    Line()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Date: \(transaction.date, format: .dateTime.month(.wide).day().year())")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .opacity(selectedTransaction?.id == transaction.id ? 1 : 0)
                        
                        Text("Balance After Transaction: \(transaction.balanceAfterTransaction, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .opacity(selectedTransaction?.id == transaction.id ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .onTapGesture {
            withAnimation(.smooth(duration: 0.25, extraBounce: 0)) {
                if selectedTransaction?.id == transaction.id {
                    // deselects the transaction if it's the one already open
                    selectedTransaction = nil
                } else {
                    // selects the new transaction and deselect others
                    selectedTransaction = transaction
                }
            }
        }
        .padding(.bottom, 0.1)
    }
    
// MARK: -ExpenseList
    @ViewBuilder
    func ExpenseItem(
        category: String,
        value: Double
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.secondary.opacity(0.1))
                .frame(height: 50)
            
            HStack {
                Text(category)
                    .font(.headline)
                
                Spacer()
                
                Text("\(value, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                    .frame(width: 100, alignment: .trailing)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 0.1)
    }
    
// MARK: -Account Transactions
    @ViewBuilder
    func accountTransactions() -> some View {
        let filteredTransactions = transactions.filter { $0.account == accountName }
        
        if filteredTransactions.isEmpty {
            VStack {
                Spacer()
                
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 100))
                    .foregroundStyle(.gray)
                
                Text("No Transactions")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title3)
                    .foregroundStyle(.gray)
                    .bold()
                
                Spacer()
            }
        } else {
            ScrollView {
                ForEach(filteredTransactions.sorted(by: { $0.date > $1.date }), id: \.id) { transaction in
                    TransactionItem(transaction: transaction)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                }
            }
        }
    }
    
// MARK: -Account Details
    @ViewBuilder
    func accountDetails() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Account Owner:")
                    .font(.headline)
                Text(players.first?.name ?? "No Player Found")
                    .padding(.bottom, 2)
                
                Text("Account Type:")
                    .font(.headline)
                Text(accountName)
                
                Line()
                
                if accountName == "Savings" || accountName == "Retirement Savings" {
                    Text("Interest Rate")
                        .font(.title2)
                        .bold()
                }
                
                if accountName == "Savings" {
                    Text("Base Interest Rate:\n0.5%")
                    
                    Text("Premium Interest Rate:\n+4% APY")
                        .padding(.bottom, 2)
                    
                    Text("Total:\n4.5% APY")
                } else if accountName == "Retirement Savings" {
                    Text("Base Interest Rate:\n7% APY")
                }
                
                if accountName == "Savings" {
                    Line()
                    
                    Text(withdrawnThisMonth
                         ? "You have withdrawn money from your savings this month. You **will not** receive the premium interest rate."
                         : "You have not withdrawn money from your savings this month. You **will** receive the premium interest rate.")
                    
                    
                    Line()
                    
                    Text("How do you get the Premium Interest Bonus?")
                        .font(.headline)
                    
                    Text("It's quite simple! Don't withdraw any money from your account for 4 weeks and you get the premium interest rate.")
                }
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
// MARK: -Weekly Expenses Transactions
    @ViewBuilder
    func weeklyExpensesTransactions() -> some View {
        Text("Weekly Expense Breakdown")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title2)
            .bold()
        
        if let player = players.first {
            let weeklyExpenses = player.weeklyExpenses
            let expenseBreakdown = breakdownExpenses(weeklyExpenses: weeklyExpenses)
            ForEach(expenseBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { category, value in
                ExpenseItem(
                    category: category,
                    value: value
                )
            }
        }
    }

// MARK: -Breakdown Expenses
    func breakdownExpenses(weeklyExpenses: Double) -> [String: Double] {
        let percentages: [String: Double] = [
            "Housing": 0.35,
            "Transportation": 0.15,
            "Food": 0.15,
            "Healthcare": 0.10,
            "Insurance & Pensions": 0.10,
            "Entertainment": 0.07,
            "Clothing": 0.03,
            "Miscellaneous": 0.05
        ]
        
        var expenseBreakdown: [String: Double] = [:]
        for (category, percentage) in percentages {
            expenseBreakdown[category] = weeklyExpenses * percentage
        }
        
        return expenseBreakdown
    }
    
    enum ViewOptions: String, CaseIterable, Hashable {
        case Transactions
        case AccountDetails
        
        var displayName: String {
            switch self {
            case .Transactions: return "Transactions"
            case .AccountDetails: return "Account Details"
            }
        }
    }
}

#Preview {
    AccountView(
        accountName: "Savings",
        accountValue: 100.00,
        isAccount: true
    )
    .fontDesign(.rounded)
}
