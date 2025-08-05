//
//  InteractiveEventMainView.swift
//  GoodCents
//
//  Created by GoodCents on 29/01/2025.
//

import SwiftUI
import SwiftData

struct InteractiveEventMainView: View {
    @Query var players: [Player]
    
    @State var randomInteractiveEvent: InteractiveEventsJSON? = nil
    @State var showLessonCover: Bool = false
    
    var interactiveEventsWealth: [InteractiveEventsWealthJSON] {
        let json = Bundle.main.decode([InteractiveEventsWealthJSON].self, from: "interactive-events.json")
        return json
    }
    
    var body: some View {
        NavigationStack {
            List {
                Text("Your wealth class is: \(players.first?.wealthClass ?? .lower)")
                    .font(.title)
                    .bold()

                ForEach(interactiveEventsWealth, id: \.id) { wealth in
                    ForEach(wealth.events) { event in
                        NavigationLink(destination: InteractiveEventActionView(event: event)) {
                            VStack {
                                Text(event.name)
                                    .font(.title)
                                    .bold()
                            }
                        }
                    }
                }
                
                Button(action: {
                    if let player = players.first {
                        randomInteractiveEvent = returnRandomInteractiveEvent(for: player)
                    }
                    showLessonCover = true
                }) {
                    Text("Open Random Event")
                        .font(.title)
                        .bold()
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { showLessonCover && randomInteractiveEvent != nil },
                set: { newValue in
                    if !newValue {
                        showLessonCover = false
                        randomInteractiveEvent = nil
                    }
                }
            )) {
                if let randomEvent = randomInteractiveEvent {
                    InteractiveEventActionView(event: randomEvent)
                } else {
                    Text("No event selected")
                }
            }
        }
    }
}
