//
//  JobOverview.swift
//  GoodCents
//
//  Created by GoodCents on 09/12/2024.
//

import SwiftUI
import SwiftData
import Confetti

struct JobOverview: View {
    @Query var job: [Job]
    @State private var jobProgress: Int = 50
    @State private var showQuiz: Bool = false
    @State private var selectedPromotionGoal: String?
    @State var showConfetti: Bool = false
    
    @AppStorage("doneThisWeeksQuiz") var doneThisWeeksQuiz: Bool = false
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                ZStack {
                    if showConfetti {
                        ConfettiSpam(showConfetti: $showConfetti, emissionDuration: 2.0)
                            .zIndex(2)
                    }
                    
                    VStack {
                        JobHeader()
                        
                        JobQuizSection()
                            .padding(.top, 3)
                            .padding(.bottom, 15)
                        
                        JobProgressionSection(selectedPromotionGoal: $selectedPromotionGoal)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showQuiz) {
            JobQuiz()
        }
        .onAppear {
            if job.first?.jobPromotionProgress == 350  {
                showConfetti = true
            }
        }
        .onDisappear {
            showConfetti = false
        }
    }
    
// MARK: -Header for Job Overview
    @ViewBuilder
    func JobHeader() -> some View {
        if let job = job.first {
            HStack(alignment: .center) {
                Image(systemName: "person")
                    .font(.system(size: 50))
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 70, height: 70)
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(job.jobTitle)
                        .font(.title)
                        .bold()
                    
                    HStack {
                        Text(String(job.jobPromotionProgress))
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 15, alignment: .leading)
                        
                        ProgressView(value: Double(job.jobPromotionProgress), total: Double(job.jobPromotionGoal))
                            .frame(maxWidth: .infinity)
                        
                             Text(String(job.jobPromotionGoal))
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 20, alignment: .trailing)
                    }
                }
                .frame(maxHeight: 70, alignment: .center)
            }
        }
    }
    
// MARK: - Job Quiz Section
    @ViewBuilder
    func JobQuizSection() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 1)
                .frame(width: 375, height: 100)
            
            VStack {
                if doneThisWeeksQuiz {
                    Text("Good Job! You've clocked into work this week! Check back next week!")
                } else {
                    Text("Looks like it's time to clock into work!")
                    Button(action: {
                        showQuiz = true
                    }) {
                        Text("Clock In!")
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 200)
                }
            }
            .frame(width: 370, height: 100)
        }
        .padding(.top, 20)
    }
    
// MARK: - Job Progress
    @ViewBuilder
    func JobProgressionSection(selectedPromotionGoal: Binding<String?>) -> some View {
        VStack {
            if let job = job.first {
                let promotionData: [(title: String, goal: Int, pay: Double)] = [
                    ("Newbie", 25, 950.24),
                    ("Apprentice", 75, 1094.43),
                    ("Professional", 150, 1175.73),
                    ("Expert", 250, 1245.89),
                    ("Master", 349, 1325.13),
                    ("Legend", 350, 1400.24)
                ]
                
                ScrollView {
                    ForEach(promotionData, id: \.title) { data in
                        let hasReachedGoal = job.jobPromotionProgress >= data.goal
                        let isCurrentGoal = job.jobPromotionGoal == data.goal
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(hasReachedGoal ? .green : isCurrentGoal ? .yellow : .gray.opacity(0.6))
                                .frame(height: selectedPromotionGoal.wrappedValue == data.title ? 110 : 50)
                                .animation(.easeInOut(duration: 0.25), value: selectedPromotionGoal.wrappedValue)
                                
                            VStack {
                                HStack {
                                    Text(data.title)
                                        .frame(width: 100, alignment: .leading)
                                        .foregroundStyle(.white)
                                    
                                    if job.jobPromotionProgress >= data.goal {
                                        ProgressView(value: Double(data.goal), total: Double(data.goal))
                                            .progressViewStyle(LinearProgressViewStyle())
                                            .frame(maxWidth: .infinity)
                                        
                                        Text("\(data.goal)/\(data.goal)")
                                            .frame(width: 80, alignment: .trailing)
                                            .foregroundStyle(.white)
                                    } else {
                                        if isCurrentGoal {
                                            ProgressView(value: Double(job.jobPromotionProgress), total: Double(data.goal))
                                                .progressViewStyle(LinearProgressViewStyle())
                                                .frame(maxWidth: .infinity)
                                        } else {
                                            Spacer()
                                        }
                                        
                                        Text("\(job.jobPromotionProgress)/\(data.goal)")
                                            .frame(width: 80, alignment: .trailing)
                                            .foregroundStyle(.white)
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .rotationEffect(.degrees(selectedPromotionGoal.wrappedValue == data.title ? 90 : 0))
                                        .foregroundStyle(.tertiary)
                                        .font(.system(size: 14, weight: .semibold))
                                        .padding(.trailing, 3)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 3)
                                
                                if selectedPromotionGoal.wrappedValue == data.title {
                                    Line()
                                        .padding(.horizontal)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Weekly Income for this promotion level: \(data.pay, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                            .foregroundStyle(.white)
                                            .padding(.horizontal)
                                            .opacity(selectedPromotionGoal.wrappedValue == data.title ? 1 : 0)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if selectedPromotionGoal.wrappedValue == data.title {
                                    selectedPromotionGoal.wrappedValue = nil
                                } else {
                                    selectedPromotionGoal.wrappedValue = data.title
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: 355)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    JobOverview()
}
