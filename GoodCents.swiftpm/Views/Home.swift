//
//  Home.swift
//  GoodCents
//
//  Created by GoodCents on 11/20/24.
//

import SwiftUI
import SwiftData

struct Home: View {
    @Query var players: [Player]
    @Query var job: [Job]
    @Query var time: [Time]
    @Query var transactions: [Transactions]
    @Query var ownedItems: [OwnedItems]
    @Query var completedLessons: [CompletedLessons]
    
    @State var showProgressTime = false
    @State private var savingsChange: Double = 0
    @State private var retirementSavingsChange: Double = 0
    @State private var expensesChange: Double = 0
    @State private var isExpandedTransfer: Bool  = false
    @State private var isExpandedItems: Bool = false
    @State private var randomInteractiveEvent: InteractiveEventsJSON?
    @State private var showInteractiveEventCover: Bool = false
    @State private var selectedItem: OwnedItems?
    
    @State private var showMeshTest: Bool = false
    
    @AppStorage("withdrawnThisMonth") var withdrawnThisMonth: Bool = false
    @AppStorage("doneThisWeeksQuiz") var doneThisWeeksQuiz: Bool = false
    @AppStorage("doneThisWeeksInteractiveEvent") var doneThisWeeksInteractiveEvent: Bool = false
    @AppStorage("completedLessonThisWeek") var completedLessonThisWeek: Bool = false
    var allowedToProgressTime: Bool {
        if completedLessons.count >= 12 {
            return doneThisWeeksQuiz && doneThisWeeksInteractiveEvent
        } else {
            return doneThisWeeksQuiz && doneThisWeeksInteractiveEvent && completedLessonThisWeek
        }
    }
    
    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
    
    @Environment(\.modelContext) var modelContext
    
    @State private var sourceAccount: PlayerAccount = .spendingAccount
    @State private var destinationAccount: PlayerAccount = .savings
    @State private var transferAmount: Double = 0
    @State private var showTransferAmount: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @FocusState private var isFocused: Bool
    
    struct AccountInfo: Identifiable {
        var id: UUID = UUID()
        var icon: String
        var title: String
        var keyPath: KeyPath<Player, Double>
        var isAccount: Bool
    }
    
    var accountItems: [AccountInfo] {
        [
            AccountInfo(icon: "creditcard", title: "Everyday Spending", keyPath: \.spendingAccount, isAccount: true),
            AccountInfo(icon: "dollarsign.circle", title: "Savings", keyPath: \.savings, isAccount: true),
            AccountInfo(icon: "clock", title: "Retirement Savings", keyPath: \.retirementSavings, isAccount: true),
            AccountInfo(icon: "creditcard", title: "Weekly Income", keyPath: \.weeklyIncome, isAccount: false),
            AccountInfo(icon: "dollarsign.circle", title: "Weekly Expenses", keyPath: \.weeklyExpenses, isAccount: false)
        ]
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Overview()
                    AccountSection()
                    OwnedItemsSection()
                    
                    Section {
                        DisclosureGroup(isExpanded: $isExpandedTransfer) {
                            if let player = players.first {
                                TransferMoney(
                                    player: player,
                                    sourceAccount: $sourceAccount,
                                    destinationAccount: $destinationAccount,
                                    transferAmount: $transferAmount,
                                    errorMessage: $errorMessage,
                                    successMessage: $successMessage
                                )
                            }
                        } label: {
                            Text("Transfer Money")
                        }
                        .onChange(of: isExpandedTransfer) {
                            if isExpandedTransfer {
                                sourceAccount = .spendingAccount
                                destinationAccount = .savings
                                transferAmount = 0
                                isFocused = false
                                errorMessage = nil
                                successMessage = nil
                            }
                        }
                    }
                    
                    Section {
                        if let time = time.first {
                            Text("It is Week: \(time.week), Month: \(time.month), Year: \(time.year)")
                        }
                        
                        Button(action: {
                            if let player = players.first {
                                randomInteractiveEvent = returnRandomInteractiveEvent(for: player)
                            }
                            showInteractiveEventCover = true
                        }) {
                            Text(doneThisWeeksInteractiveEvent ? "You've completed this weeks Interactive Event!!" : "Complete this week's Interactive Event")
                        }
                        .disabled(doneThisWeeksInteractiveEvent)
                        
                        if allowedToProgressTime {
                            Button(action: {
                                showProgressTime = true
                                forwardTime(
                                    savingsChange: &savingsChange,
                                    retirementSavingsChange: &retirementSavingsChange,
                                    expensesChange: &expensesChange
                                )
                            }) {
                                Text("Progress Time")
                            }
                            .disabled(!doneThisWeeksInteractiveEvent)
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("To Progress Time you need to complete the following:")
                                
                                HStack {
                                    Image(systemName: doneThisWeeksQuiz ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(doneThisWeeksQuiz ? .green : .gray)
                                    Text("Clock into work")
                                        .foregroundStyle(doneThisWeeksQuiz ? .green : .red)
                                }
                                
                                HStack {
                                    Image(systemName: doneThisWeeksInteractiveEvent ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(doneThisWeeksInteractiveEvent ? .green : .gray)
                                    Text("Complete an Interactive Event")
                                        .foregroundStyle(doneThisWeeksInteractiveEvent ? .green : .red)
                                }
                                
                                if completedLessons.count < 12 {
                                    HStack {
                                        Image(systemName: completedLessonThisWeek ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(completedLessonThisWeek ? .green : .gray)
                                        Text("Complete a Lesson")
                                            .foregroundStyle(completedLessonThisWeek ? .green : .red)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Welcome \(players.first?.name ?? "Player")")
            .fullScreenCover(isPresented: $showProgressTime) {
                ProgressTime(
                    savingsChange: savingsChange,
                    retirementSavingsChange: retirementSavingsChange,
                    expensesChange: expensesChange
                )
            }
            .fullScreenCover(isPresented: Binding(
                get: { showInteractiveEventCover && randomInteractiveEvent != nil },
                set: { newValue in
                    if !newValue {
                        randomInteractiveEvent = nil
                        showInteractiveEventCover = false
                    }
                }
            )) {
                if let randomEvent = randomInteractiveEvent {
                    InteractiveEventActionView(event: randomEvent)
                } else {
                    Text("No event found")
                }
            }
        }
    }
    
// MARK: -Time Progression Function
    func forwardTime(
        savingsChange: inout Double,
        retirementSavingsChange: inout Double,
        expensesChange: inout Double
    ) {
        let increase = Double.random(in: 0...1) < 0.8
        
        if let time = time.first {
            time.week += 1

            // Handle week overflow
            if time.week > 4 {
                time.week = 1
                time.month += 1

                // Handle month overflow
                if time.month > 12 {
                    time.month = 1
                    time.year += 1
                }
            }
            
            try? modelContext.save()
            
            // Interest on savings and recalculate expenses
            if time.week == 1, let player = players.first {
                let oldSavings = player.savings
                let oldRetirementSavings = player.retirementSavings
                let oldExpenses = player.weeklyExpenses
                
                // Updates savings and expenses
                // Increases savings and retirement savings if withdrawnThisMonth by 0.04167% and 0.0625% respectively
                // Increases savings and retirement savings if not withdrawnThisMonth by 0.375% and 0.583% respectively
                if withdrawnThisMonth {
                    player.savings += player.savings * 0.0004166667
                } else {
                    player.savings += player.savings * 0.00375
                }
                
                player.retirementSavings += player.retirementSavings * 0.0064583333
                
                // Increase or decrease weekly expenses
                if increase {
                    player.weeklyExpenses = generateWeeklyExpenses(weeklyIncome: players.first?.weeklyIncome ?? job.first?.jobIncome ?? 0)
                }
                
                // Calculate the change in savings and expenses
                savingsChange = player.savings - oldSavings
                retirementSavingsChange = player.retirementSavings - oldRetirementSavings
                expensesChange = player.weeklyExpenses - oldExpenses
                
                let withdrawMessage = withdrawnThisMonth ? "Interest" : "Premium Interest"
                
                Transactions.saveTransaction(
                    account: "Savings",
                    name: withdrawMessage,
                    value: savingsChange,
                    balanceAfterTransaction: player.savings,
                    context: modelContext
                )
                
                Transactions.saveTransaction(
                    account: "Retirement Savings",
                    name: "Interest",
                    value: retirementSavingsChange,
                    balanceAfterTransaction: player.retirementSavings,
                    context: modelContext
                )
                
                try? modelContext.save()
            }
        }

        // Receive income and pay expenses
        if let player = players.first {
            player.spendingAccount += player.weeklyIncome
            let balanceAfterTransactionReceive = player.spendingAccount
            Transactions.saveTransaction(
                account: "Everyday Spending",
                name: "Weekly Income",
                value: player.weeklyIncome,
                balanceAfterTransaction: balanceAfterTransactionReceive,
                context: modelContext
            )
            
            player.spendingAccount -= player.weeklyExpenses
            let balanceAfterTransactionSpend = player.spendingAccount
            Transactions.saveTransaction(
                account: "Everyday Spending",
                name: "Weekly Expenses",
                value: -player.weeklyExpenses,
                balanceAfterTransaction: balanceAfterTransactionSpend,
                context: modelContext
            )
            
            try? modelContext.save()
        }
        
        doneThisWeeksQuiz = false
        doneThisWeeksInteractiveEvent = false
        completedLessonThisWeek = false
        withdrawnThisMonth = false
    }
    
// MARK: - Income and Expenses Overview
    @ViewBuilder
    func Overview() -> some View {
        Section(header: Text("Income and Expenses")) {
            ListItem(
                icon: "creditcard",
                title: "Weekly Income",
                playerVar: \.weeklyIncome,
                players: players,
                isAccount: false
            )
            NavigationLink(destination:
                AccountView(
                    accountName: "Weekly Expenses",
                    accountValue: players.first?[keyPath: \.weeklyExpenses] ?? 0,
                    isAccount: false
                )) {
                    ListItem(
                        icon: "dollarsign.circle",
                        title: "Weekly Expenses",
                        playerVar: \.weeklyExpenses,
                        players: players,
                        isAccount: false
                    )
                }
        }
    }

// MARK: - Bank Account Sections
    @ViewBuilder
    func AccountSection() -> some View {
        Section(header: Text("Bank Accounts")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(accountItems.filter { $0.isAccount }) { item in
                        NavigationLink(destination:
                        AccountView(
                            accountName: item.title,
                            accountValue: players.first?[keyPath: item.keyPath] ?? 0,
                            isAccount: item.isAccount
                        )) {
                            HorizontalListItem(
                                icon: item.icon,
                                title: item.title,
                                playerVar: item.keyPath,
                                players: players,
                                isAccount: item.isAccount
                            )
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
        }
    }
    
// MARK: - Owned Items Section
    @ViewBuilder
    func OwnedItemsSection() -> some View {
        if !ownedItems.isEmpty {
            Section(header: Text("Owned Items").bold()) {
                if ownedItems.count < 3 {
                    ForEach(ownedItems) { item in
                        if let player = players.first {
                            OwnedItemListItem(item: item, player: player, selectedItem: $selectedItem)
                        }
                    }
                } else {
                    DisclosureGroup(isExpanded: $isExpandedTransfer) {
                        ForEach(ownedItems) { item in
                            if let player = players.first {
                                OwnedItemListItem(item: item, player: player, selectedItem: $selectedItem)
                            }
                        }
                    } label: {
                        Text("Owned Items")
                    }
                }
            }
        }
    }
}

#Preview {
    Home()
}
