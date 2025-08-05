//
//  InteractiveEventActionView.swift
//  GoodCents
//
//  Created by GoodCents on 29/01/2025.
//

import SwiftUI
import SwiftData

struct InteractiveEventActionView: View {
    @Query var players: [Player]
    @Query var ownedItems: [OwnedItems]
    
    let event: InteractiveEventsJSON
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State var showOutcome: Bool = false
    @State var selectedAction: InteractiveEventsActionsJSON? = nil
    @State var transferAmount: Double = 0
    @State var errorMessage: String?
    @State var successMessage: String?
    @State var sourceAccountBalanace: Double = 0
    @State private var randomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.interactiveEventColors)
    
    @FocusState var isFocused: Bool
    
    @AppStorage("withdrawnThisMonth") var withdrawnThisMonth: Bool = false
    @AppStorage("doneThisWeeksInteractiveEvent") var doneThisWeeksInteractiveEvent: Bool = false
    
    let meshTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                        randomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.interactiveEventColors)
                    }
                }
                .zIndex(-1)
                
                VStack {
                    if !showOutcome, let action = event.actions.first?.type {
                        returnActionView(for: action, event: event)
                            .statusBar(hidden: true)
                    } else if showOutcome, let action = selectedAction {
                        outcomeView(for: action, outcome: generateTransferOutcome(for: action.outcome, transferAmount: transferAmount))
                    } else {
                        Text("No action selected")
                    }
                }
            }
        }
    }
    
// MARK: - function for performing an action
    func performAction(_ action: InteractiveEventsActionsJSON) {
        switch action.type {
        case .purchase:
            purchaseItem(action.item!)
            showOutcome = true
        case .transfer:
            transferFunds(
                to: action.transfer!.destinationAccount,
                from: action.transfer!.sourceAccount,
                transferAmount: transferAmount,
                player: players.first!,
                modelContext: modelContext,
                errorMessage: &errorMessage,
                successMessage: &successMessage,
                withdrawnThisMonth: &withdrawnThisMonth
            )
            showOutcome = true
        case .dismiss:
            showOutcome = true
        }
    }

// MARK: - function for purchasing an item
    func purchaseItem(_ item: InteractionEventsItemJSON) {
        if let player = players.first {
            player.spendingAccount -= item.price
        }
        let balanceAfterTransaction = players.first?.spendingAccount ?? 0
        
        if let existingItem = ownedItems.first(where: { $0.itemName == item.name }) {
            existingItem.itemQuantity += 1
        } else {
            let newItem = OwnedItems(
                itemName: item.name,
                itemPrice: item.price,
                itemIcon: item.icon,
                itemIsSellable: item.isSellable,
                itemQuantity: 1,
                itemValue: item.value
            )
            modelContext.insert(newItem)
        }
        
        Transactions.saveTransaction(
            account: "Everyday Spending",
            name: "Purchased \(item.name)",
            value: -item.price,
            balanceAfterTransaction: balanceAfterTransaction,
            context: modelContext
        )
        try? modelContext.save()
    }
    
// MARK: - view for purchasing actions
    @ViewBuilder
    func purchaseView(for event: InteractiveEventsJSON) -> some View {
        Text(event.description)
            .padding()
        
        HStack {
            ForEach(event.actions) { action in
                Button(action: {
                    performAction(action)
                    selectedAction = action
                }) {
                    Text(action.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.top, 4)
    }
    
// MARK: - view for transfer actions
    @ViewBuilder
    func transferView(for event: InteractiveEventsJSON) -> some View {
        VStack {
            Text(event.description)
                .padding()
            
            ForEach(event.actions) { action in
                if action.type == .transfer, let transfer = action.transfer, let player = players.first {
                    let minAmount = transfer.minAmount
                    let sourceBalance = player.balance(for: transfer.sourceAccount)
                    let destinationBalance = player.balance(for: transfer.destinationAccount)
                    let upperBound = max(minAmount, sourceBalance)
                    
                    VStack {
                        HStack {
                            VStack {
                                Image(systemName: transfer.sourceAccountIcon)
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white)
                                    .frame(width: 66, height: 66)
                                    .background(
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 66, height: 66)
                                    )
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                
                                Text(transfer.sourceAccount.rawValue)
                                Text("Balance: $\(sourceBalance, specifier: "%.2f")")
                                    .font(.caption)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                                .symbolEffect(.wiggle)
                                .padding(.horizontal)
                            
                            VStack {
                                Image(systemName: transfer.destinationAccountIcon)
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white)
                                    .frame(width: 66, height: 66)
                                    .background(
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 66, height: 66)
                                    )
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                
                                Text(transfer.destinationAccount.rawValue)
                                Text("Balance: $\(destinationBalance, specifier: "%.2f")")
                                    .font(.caption)
                            }
                        }
                        .frame(alignment: .center)
                        
                        
                        HStack {
                            TextField("Transfer Amount", value: $transferAmount, formatter: Home().currencyFormatter)
                                .padding(4)
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(8)
                                .keyboardType(.decimalPad)
                                .focused($isFocused)
                                .onChange(of: transferAmount) {
                                    if transferAmount < minAmount {
                                        transferAmount = minAmount
                                    } else if transferAmount > upperBound {
                                        transferAmount = upperBound
                                    }
                                }
                                .toolbar {
                                    ToolbarItem(placement: .keyboard) {
                                        Button("Dismiss") {
                                            isFocused = false
                                        }
                                    }
                                }
                            
                            Slider(
                                value: $transferAmount,
                                in: minAmount...upperBound
                            )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            HStack {
                ForEach(event.actions) { action in
                    Button(action: {
                        performAction(action)
                        selectedAction = action
                    }) {
                        Text(action.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 4)
        }
        .gesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .onAppear {
            transferAmount = event.actions.first?.transfer?.minAmount ?? 0
        }
    }
    
// MARK: - view for bank balances
    @ViewBuilder
    func itemPriceView(for item: InteractionEventsItemJSON, player: Player) -> some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: "creditcard")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                        .frame(width: 82.5, height: 82.5)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 82.5, height: 82.5)
                        )
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Text("Everyday Spending")
                    Text("Balance: \(player.spendingAccount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: item.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                        .frame(width: 82.5, height: 82.5)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 82.5, height: 82.5)
                        )
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Text(item.name)
                    Text("Price: \(item.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .font(.caption)
                }
            }
            .padding(.horizontal)
        }
    }
    
// MARK: - view for outcome of actions
    @ViewBuilder
    func outcomeView(for action: InteractiveEventsActionsJSON, outcome: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.white.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding()
                .frame(maxWidth: 400, maxHeight: action.type == .transfer ? 250 : 225)
            
            VStack {                
                Text(outcome)
                    .padding()
                
                Button(action: {
                    dismiss()
                    doneThisWeeksInteractiveEvent = true
                }) {
                    Text("Close")
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: 350, maxHeight: 225)
            .padding(.horizontal)
        }
    }
    
// MARK: - view that returns the correct view based on action
    @ViewBuilder
    func returnActionView(for action: ActionTypes, event: InteractiveEventsJSON) -> some View {
        switch action {
        case .purchase:
            VStack {
                Text(event.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 5)
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.white.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding()
                        .frame(maxWidth: 400, maxHeight: 200)
                    
                    VStack {
                        if let firstAction = event.actions.first {
                            itemPriceView(for: firstAction.item!, player: players.first!)
                                .frame(maxWidth: 350, maxHeight: 200)
                        }
                    }
                    .padding(.horizontal)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.white.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding()
                        .frame(maxWidth: 400, maxHeight: 300)
                    
                    VStack {
                        purchaseView(for: event)
                    }
                    .frame(maxWidth: 350, maxHeight: 300)
                    .padding(.horizontal)
                }
                
            Spacer()
            }
        case .transfer:
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.white.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding()
                    .frame(maxWidth: 400, maxHeight: 450)
                
                VStack {
                    transferView(for: event)
                }
                .frame(maxWidth: 350, maxHeight: 450)
                .padding(.horizontal)
            }
        case .dismiss:
            Text("Dismissed Event")
        }
    }
    
// MARK: - generates the outcome text (and formats it if a transfer outcome)
    func generateTransferOutcome(for actionOutcome: String, transferAmount: Double) -> String {
        let roundedAmount = String(format: "%.2f", transferAmount)
        let transferOutcome = actionOutcome.replacingOccurrences(of: "${amount}", with: "$\(roundedAmount)")
        return transferOutcome
    }
}
