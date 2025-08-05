//
//  InteractiveEvents.swift
//  GoodCents
//
//  Created by GoodCents on 28/01/2025.
//

import SwiftUI

enum WealthClasses: String, Codable {
    case lower, middle, upper
}

enum ActionTypes: String, Codable {
    case purchase, transfer, dismiss
}

struct InteractiveEventsWealthJSON: Codable, Identifiable {
    let id: Int
    let wealthClass: [WealthClasses]
    let events: [InteractiveEventsJSON]
}

struct InteractiveEventsJSON: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let actions: [InteractiveEventsActionsJSON]
}

struct InteractiveEventsActionsJSON: Codable, Identifiable {
    let id: Int
    let title: String
    let type: ActionTypes
    let amount: Double?
    let item: InteractionEventsItemJSON?
    let transfer: InteractiveEventsTransferJSON?
    let outcome: String
}

struct InteractionEventsItemJSON: Codable, Identifiable {
    let id: Int
    let name: String
    let icon: String
    let price: Double
    let value: Double
    let isSellable: Bool
}

struct InteractiveEventsTransferJSON: Codable, Identifiable {
    let id: Int
    let sourceAccountIcon: String
    let destinationAccountIcon: String
    let sourceAccount: PlayerAccount
    let destinationAccount: PlayerAccount
    let minAmount: Double
    let maxAmount: Double?
}

func calculatePlayersWealthClass(_ money: Double) -> WealthClasses {
    switch money {
    case 0..<1000:
        return .lower
    case 1000..<10000:
        return .middle
    default:
        return .upper
    }
}

// this function calculates the 'weight' (chance) of the event happening based on player stats
/// weight is the same as chance when its referenced in this code for future reference (im gonna forget >.<)
func calculateRandomChanceWeight(for event: InteractiveEventsJSON, player: Player) -> Double {
    var weight: Double = 1.0
    
    for action in event.actions {
        switch action.type {
        case .transfer:
            if let transfer = action.transfer {
                let playerSourceBalance = player.balance(for: transfer.sourceAccount)
                let canPlayerTransfer = playerSourceBalance >= transfer.minAmount
                
                // if player can transfer the money then increase the weight
                weight += canPlayerTransfer ? 2.0 : -1.0
                
                // increase weight if the account is `underfunded` (stupid name, just if low on money then reward player (makes sense ))
                let playerDestinationBalance = player.balance(for: transfer.destinationAccount)
                
                // account is considered underfunded if its balance is less than the threshold set in PlayerAccount enum (found in SwiftDataModels.swift)
                // and since this 'algorithm' kinda sucks, it double checks that the source account balance is greater than destination account balance, otherwise it doesn't increase the weight
                let underfunded = playerDestinationBalance < transfer.destinationAccount.underfundedThreshold
                let shouldActuallyTransfer = underfunded && playerSourceBalance > playerDestinationBalance
                if shouldActuallyTransfer {
                    weight += 1.5
                } else {
                    weight -= 5.0
                }
            }
            
        case .purchase:
            if let price = action.item?.price ?? action.amount, player.spendingAccount >= price {
                // if price is less than the players spending account then increase the weight
                weight += player.spendingAccount >= price ? 1.0 : -1.0
            } else {
                weight -= 5.0
            }
            
        case .dismiss:
            // neutral event action, doesn't affect weight
            weight += 0.5
        }
    }
    
    // special case for if the player is low on money in spending account
    if player.spendingAccount < 200 {
        let actionHasTransfer = event.actions.contains { action in
            if case .transfer = action.type,
               let transfer = action.transfer,
               transfer.destinationAccount == .spendingAccount,
               transfer.minAmount <= player.spendingAccount {
                return true
            }
            return false
        }
        if actionHasTransfer {
            weight *= 2.0
        }
    }
    
    return max(weight, 0.0)
}

// actual function that returns a 'random' interactive event based on weight
/// lots of variables get defined in this function but, my code works so i'm happy
func returnRandomInteractiveEvent(for player: Player) -> InteractiveEventsJSON {
    let wealthClass = player.wealthClass
    let allEvents = Bundle.main.decode([InteractiveEventsWealthJSON].self, from: "interactive-events.json")
    
    // filter the wealth groups to the ones that the player is apart of. (Should only return 1 group)
    let matchedWealthGroups = allEvents.filter { $0.wealthClass.contains(wealthClass) }
    
    // for each event in the matched wealth group, calculate the weight of the event
    var eligibleEvents = [(event: InteractiveEventsJSON, weight: Double)]()
    for group in matchedWealthGroups {
        for event in group.events {
            let weight = calculateRandomChanceWeight(for: event, player: player)
            eligibleEvents.append((event, weight))
        }
    }
    
    // filter to those with a positive weight (greater than zero)
    let filteredEvents = eligibleEvents.filter { $0.weight > 0 }
    guard !filteredEvents.isEmpty else {
        return InteractiveEventsJSON(id: 0, name: "No events found", description: "No events found", actions: [])
    }
    
    let totalWeight = filteredEvents.reduce(0) { $0 + $1.weight }
    let random = Double.random(in: 0..<totalWeight)
    var cumulativeWeight = 0.0
    
    // return the event that the random number falls into the range of
    for (event, weight) in filteredEvents {
        cumulativeWeight += weight
        if random < cumulativeWeight {
            return event
        }
    }
     
    return filteredEvents.first?.event ?? InteractiveEventsJSON(id: 0, name: "No events found", description: "No events found", actions: [])
}
