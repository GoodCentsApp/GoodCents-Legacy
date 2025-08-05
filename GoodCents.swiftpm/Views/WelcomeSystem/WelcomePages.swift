//
//  WelcomePages.swift
//  GoodCents
//
//  Created by GoodCents on 21/11/2024.
//
import SwiftUI
import SwiftData

//MARK: -WelcomePage1
struct WelcomePage1: View {
    @Query var players: [Player]
    @State private var name: String = ""
    @Binding var currentPage: Int
    @FocusState private var isFocused: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext

    @AppStorage("isInitialised") private var isInitialised = false
    
    var body: some View {
        VStack {
            SheetHeader(
                imageName: "WelcomeIcon",
                title: "Welcome to GoodCents!",
                subtitle: "GoodCents helps you with money sense!",
                backgroundColor: .blue,
                isCustomImage: true
            )
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                FeaturePointView(
                    title: "Learn to manage your money",
                    subTitle: "Track your spending and saving to become a money master.",
                    imageName: "dollarsign.circle"
                )
                
                FeaturePointView(
                    title: "Prepare for your future!",
                    subTitle: "Learn how to budget and save for the future.",
                    imageName: "clock"
                )
                
                FeaturePointView(
                    title: "Master your job!",
                    subTitle: "Climb the ranks at your job and earn promotions.",
                    imageName: "chart.bar.xaxis"
                )
            }
            
            Spacer()
            
            Text("To begin your journey, enter your name:")
                .padding(.top)
                .padding(.horizontal)
            
            if let player = players.first {
                HStack {
                    TextField("Name", text: Binding(
                        get: { player.name },
                        set: { player.name = $0 }
                    ))
                    .focused($isFocused)
                    .padding(10)
                    .cornerRadius(8)
                    .shadow(radius:1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.8) : Color.gray.opacity(0.1), lineWidth: 0.5)
                    )
                    .frame(width: 300)
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            withAnimation {
                                isFocused = false
                            }
                        }
                        .opacity(isFocused ? 1 : 0)
                }
            }

            
            Spacer(minLength: 120)
            
            Button(action: {
                do {
                    try modelContext.save()
                } catch {
                    print("Failed to save player: \(error.localizedDescription)")
                }
                currentPage += 1
            }) {
                Text("Next")
                    .font(.title3)
                    .bold()
                    .frame(width: 300, height: 40)
            }
            .buttonStyle(.borderedProminent)
            .sensoryFeedback(.selection, trigger: currentPage)
        }
        .onAppear {
            createInitialPlayer()
            initTime()
        }
    }
    
    // MARK: Create player
    private func createInitialPlayer() {
        guard !isInitialised else { return }
        isInitialised = true

        // Create the initial job
        let newJob = Job(
            jobPromotionProgress: 0
        )
        modelContext.insert(newJob)

        // Create the player and link the job
        let newPlayer = Player(name: "Player 1", job: newJob)
        modelContext.insert(newPlayer)

        // Save the context
        do {
            try modelContext.save()
        } catch {
            print("Failed to create initial player or job: \(error.localizedDescription)")
        }
    }
    
    // MARK: Create time
    private func initTime() {
        let newTime = Time(week: 1, month: 1, year: 1)
        modelContext.insert(newTime)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to create initial time: \(error.localizedDescription)")
        }
    }
}

// MARK: -WelcomePage2
struct WelcomePage2: View {
    @Binding var currentPage: Int
    @Query var players: [Player]
    
    var body: some View {
        VStack {
            if let player = players.first {
                SheetHeader(
                    imageName: "book",
                    title: "Your Journey Begins",
                    subtitle: "",
                    backgroundColor: .accentColor
                )
                
                ScrollView {
                    // text for sections
                    let sections = [
                        ("You are an 18 year old fresh out of high school.\n\nYou just landed your first job at Appleseed Orchards and are trying to learn how to manage your money.", 150),
                        ("Currently you make \(String(format: "$%.2f", player.weeklyIncome)) a week and spend \(String(format: "$%.2f", player.weeklyExpenses)) a week.\n\nYou start off with \(String(format: "$%.2f", player.spendingAccount)) in your spending account, \(String(format: "$%.2f", player.savings)) in savings, and \(String(format: "$%.2f", player.retirementSavings)) in retirement savings.", 160),
                        ("Every week there is a chance of a random event happening, this could either be beneficial to you or it could be detrimental.\nThere is also a mandatory Interactive Event you must complete every week to proceed.", 160),
                        ("Every month, you gain interest on your savings and there is a chance your expenses either increase or decrease.\n\nYou can also complete lessons to boost your knowledge!.", 150)
                    ]
                    
                    // create the sections
                    ForEach(sections.indices, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.secondary.opacity(0.2))
                                .frame(height: CGFloat(sections[index].1))
                            
                            VStack {
                                Text(sections[index].0)
                                    .padding()
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    currentPage += 1
                }) {
                    Text("Next")
                        .font(.title3)
                        .bold()
                        .frame(width: 300, height: 40)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: -WelcomePage3
struct WelcomePage3: View {
    @Binding var currentPage: Int
    @Query var players: [Player]
    @Query var time: [Time]
    @State private var showSkipWarning = false
    
    @AppStorage("completedWelcome") private var completedWelcome = true
    @AppStorage("completedTutorial") private var completedTutorial = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        SheetHeader(
            imageName: "circle.dashed",
            title: "Your Goals",
            subtitle: "Complete these goals to win the game!",
            backgroundColor: .blue
        )
        
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 30) {
                WelcomeGoalView(
                    title: "Ascend the ranks!",
                    description: "Reach Master promotion at Appleseed Orchards.",
                    progress: 0
                )
                
                WelcomeGoalView(
                    title: "Save for the future",
                    description: "Save $10,000 in your Retirement Savings account.",
                    progress: (players.first?.retirementSavings ?? 0) / 10000
                )
                
                WelcomeGoalView(
                    title: "Become the Money Genius!",
                    description: "Complete all the lessons in lessons tab.",
                    progress: 0
                )   
                
                HStack {
                    Image(systemName: "trophy.circle")
                        .frame(width: 150, height: 70)
                        .font(.system(size: 80))
                        .foregroundStyle(.primary.opacity(0.2))
                    
                    
                    VStack(alignment: .leading) {
                        Text("Complete all goals")
                            .font(.title2)
                            .bold()
                        
                        Text("Complete all the goals to win the game!")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                    }
                }
            }
            
            Spacer()
            Spacer()
            
            Button(action: {
                completedWelcome = true
                dismiss()
            }) {
                Text("Let's Begin!")
                    .font(.title3)
                    .bold()
                    .frame(width: 300, height: 40)
            }
            .sensoryFeedback(.success, trigger: completedWelcome)
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 10)
            
            Button(action: {
                showSkipWarning = true
            }) {
                Text("Skip Tutorial")
            }
        }
        .confirmationDialog("Are you sure you want to skip the tutorial?", isPresented: $showSkipWarning) {
            Button("Yes", role: .destructive) {
                completedTutorial = true
                completedWelcome = true
                dismiss()
            }
        } message: {
            Text("Are you sure you want to skip the tutorial?\nYou will not be able to access it again.")
        }
    }
    
// MARK: - Goal Ring Items
    @ViewBuilder
    func WelcomeGoalView(title: String, description: String, progress: Double, lineWidth: CGFloat = 10) -> some View {
        HStack {
            CircularProgressView(progress: progress, lineWidth: lineWidth)
                .frame(width: 150, height: 70)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Welcome View (Brings pages together)
struct WelcomeView: View {
    // store in appstorage so it auto resumes if someone quits mid setup
    @AppStorage("currentPage") var currentPage: Int = 0
    
    var body: some View {
        VStack {
            if currentPage == 0 {
                WelcomePage1(currentPage: $currentPage)
            } else if currentPage == 1 {
                WelcomePage2(currentPage: $currentPage)
            } else if currentPage == 2 {
                WelcomePage3(currentPage: $currentPage)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

#Preview {
    WelcomePage1(
        currentPage: .constant(2)
    )
}
