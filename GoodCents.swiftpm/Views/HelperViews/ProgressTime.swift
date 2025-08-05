//
//  ProgressTime.swift
//  GoodCents
//
//  Created by GoodCents on 11/21/24.
//

import SwiftUI
import SwiftData

// MARK: -Progress Time Struct
struct ProgressTime: View {
    @Query var time: [Time]
    @Query var players: [Player]
    
    @State private var randomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.progressTimeColors)
    @State private var dots = ""
    @State private var timer: Timer? = nil
    @State var showResults = false
    @State var savingsChange: Double
    @State var retirementSavingsChange: Double
    @State var expensesChange: Double
    @State var currentEvent: WeeklyEvent?
    @State var progressValue: Double = 0
    @State var countdownTask: Task<Void, Never>?
    
    let meshTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext

// MARK: -Main View
    var body: some View {
        ZStack {
            meshGradientBG()
            
            progressingTimeAnimation()
            
            if showResults {
                showResultsView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    showResults = true
                }
            }
            // this timer is for dots animation
            startTimer()
            
            triggerWeeklyEvent()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
// MARK: -Start Timer for the dots animation
    private func startTimer() {
        var dotCount = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                dotCount = (dotCount + 1) % 4
                withAnimation(.easeInOut(duration: 0.15)) {
                    dots = String(repeating: ".", count: dotCount)
                }
            }
        }
    }
    
// MARK: -Mesh Gradient Background
    @ViewBuilder
    func meshGradientBG() -> some View {
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
                randomColorSet = MeshGradientValues.randomColors(from: MeshGradientValues.progressTimeColors)
            }
        }
        .zIndex(-1)
    }
    
// MARK: -Spinning Clock and Animated Dots
    @ViewBuilder
    func progressingTimeAnimation() -> some View {
        VStack {
            Image(systemName: "clock")
                .font(.system(size: 200))
                .symbolEffect(.rotate.byLayer, options: .repeat(2))
                .foregroundStyle(.white.opacity(0.5))
            
            Text("Progressing Time" + dots)
                .font(.title)
                .bold()
                .foregroundStyle(.white.opacity(0.6))
        }
        .opacity(showResults ? 0 : 1)
        .animation(.easeInOut(duration: 1), value: showResults)
    }
    
// MARK: -Results screen
    @ViewBuilder
    func showResultsView() -> some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if let week = time.first {
                    Spacer()
                    
                    Text("It is now Week \(week.week)")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.6))
                        .bold()
                    
                    if week.week == 1 {
                        VStack(alignment: .center, spacing: 20) {
                            Text("Savings increased by $\(String(format: "%.2f", savingsChange))")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(nil)
                            
                            Text("Retirement savings increased by $\(String(format: "%.2f", retirementSavingsChange))")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(nil)
                            
                            if expensesChange != 0 {
                                Text((expensesChange < 0 ? "Expenses have decreased" : "Expenses have increased") +
                                     " by $\(String(format: "%.2f", expensesChange))")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(nil)
                            }
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.1))
                        )
                    }
                    
                    if currentEvent != nil {
                        VStack(alignment: .center) {
                            Text(currentEvent!.title)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Text(currentEvent!.body)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Text(currentEvent!.amountString)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.1))
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 5)
                                    .foregroundStyle(.white.opacity(0.6))
                                
                                Circle()
                                    .trim(from: 0, to: progressValue)
                                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                    .foregroundStyle(.white)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1.5), value: progressValue)
                            }
                            .frame(width: 30, height: 30)
                            
                            Text("Dismiss")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                        }
                        .frame(width: 300, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .padding()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .opacity(showResults ? 1 : 0)
        .animation(.easeInOut(duration: 1.5), value: showResults)
        .transition(.opacity)
        .onAppear {
            let delay = currentEvent!.isMoneyOwed ? 10 : 6
            startCountdownTimer(delay: delay)
        }
        .onDisappear {
            countdownTask?.cancel()
        }
    }
    
// MARK: - starts timer that dismisses the view
    func startCountdownTimer(delay: Int) {
        countdownTask = Task {
            let totalSteps = delay * 10 // Update 10 times per second
            let stepInterval = 0.1 // Seconds
            
            for step in 1...totalSteps {
                if Task.isCancelled { return }
                
                await MainActor.run {
                    progressValue = Double(totalSteps - step) / Double(totalSteps)
                }
                
                try? await Task.sleep(nanoseconds: UInt64(stepInterval * 1_000_000_000))
            }
            
            await MainActor.run {
                Home().showProgressTime = false
                dismiss()
            }
        }
    }
    
// MARK: -Trigger random for weekly event
    func triggerWeeklyEvent() {
        let chance: Double = 1
        let randomChance = Double.random(in: 0...1) < chance
        currentEvent = nil
        
        if randomChance {
            if let randomEvent = getRandomWeeklyEvent() {
                currentEvent = randomEvent
                
                if currentEvent!.isMoneyOwed {
                    players.first?.spendingAccount -= currentEvent!.amount
                } else {
                    players.first?.spendingAccount += currentEvent!.amount
                }
                let balanceAfterTransaction = players.first?.spendingAccount ?? 0 - currentEvent!.amount
                Transactions.saveTransaction(
                    account: "Everyday Spending",
                    name: currentEvent!.title,
                    value: currentEvent!.isMoneyOwed ? -currentEvent!.amount : currentEvent!.amount,
                    balanceAfterTransaction: balanceAfterTransaction,
                    context: modelContext
                )
            }
        }
    }
}

#Preview {
    ProgressTime(
        savingsChange: 0.45,
        retirementSavingsChange: 0.35,
        expensesChange: 0.25,
        currentEvent: WeeklyEvent(
            title: "Random Event",
            body: "This is a random event that could happen",
            isMoneyOwed: true,
            amount: 100
        )
    )
        .fontDesign(.rounded)
}
