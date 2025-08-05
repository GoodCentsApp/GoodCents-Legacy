//
//  WeeklyEvent.swift
//  GoodCents
//
//  Created by GoodCents on 13/12/2024.
//

import Foundation

// MARK: - weekly event model
struct WeeklyEvent {
    var title: String
    var body: String
    var isMoneyOwed: Bool
    var amount: Double
    
    var amountString: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        
        if isMoneyOwed {
            let amountString = currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
            return "You lost \(amountString)"
        } else {
            let amountString = currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
            return "You Gained \(amountString)"
        }
    }
}

// MARK: - get random weekly event
func getRandomWeeklyEvent() -> WeeklyEvent? {
    let positiveWeeklyEvents: [WeeklyEvent] = [
        WeeklyEvent(title: "Bonus at Work", body: "You received an unexpected bonus at work this week!", isMoneyOwed: false, amount: 500.00),
        WeeklyEvent(title: "Unexpected Gift", body: "A friend gave you a surprise gift just because! You feel grateful.", isMoneyOwed: false, amount: 100.00),
        WeeklyEvent(title: "Health Insurance Refund", body: "Your health insurance overcharged you, and they issued a refund.", isMoneyOwed: false, amount: 200.00),
        WeeklyEvent(title: "Car Insurance Discount", body: "Your car insurance gave you a nice discount after you completed a defensive driving course.", isMoneyOwed: false, amount: 100.00),
        WeeklyEvent(title: "Concert Cancelled", body: "The concert you were looking forward to got canceled due to unforeseen circumstances. Fortunately you received a refund!", isMoneyOwed: false, amount: 90.00),
        WeeklyEvent(title: "Free Coffee", body: "You received a free coffee at your usual cafe as part of their loyalty program.", isMoneyOwed: false, amount: 5.00),
        WeeklyEvent(title: "WiFi Outage", body: "Your WiFi service went out for a few days, disrupting your work and entertainment. They gave you $20 as restitution", isMoneyOwed: false, amount: 20.00),
        WeeklyEvent(title: "Surprise Inheritance", body: "You received an unexpected inheritance from a distant relative!", isMoneyOwed: false, amount: 1500.00),
        WeeklyEvent(title: "Found Money", body: "You found some money on the street and decided to keep it.", isMoneyOwed: false, amount: 50.00),
        WeeklyEvent(title: "Tax Refund", body: "You received a tax refund from the government.", isMoneyOwed: false, amount: 300.00),
        WeeklyEvent(title: "Gift Card", body: "You received a gift card from a store as a thank you for being a loyal customer.", isMoneyOwed: false, amount: 25.00),
        WeeklyEvent(title: "Freelance Job", body: "You completed a freelance job and got paid for it.", isMoneyOwed: false, amount: 200.00),
        WeeklyEvent(title: "Power Outage", body: "A power outage in your neighborhood lasts a few days, disrupting your work and home routine. As restitution, you got $100!", isMoneyOwed: false, amount: 100.00),
        WeeklyEvent(title: "Free Meal", body: "You received a free meal at a restaurant as part of their promotion.", isMoneyOwed: false, amount: 30.00),
    ]

    let negativeWeeklyEvents: [WeeklyEvent] = [
        WeeklyEvent(title: "Flat Tyre", body: "You got a flat tyre on your way to work and had to pay for a tow truck.", isMoneyOwed: true, amount: 100.00),
        WeeklyEvent(title: "Accidental Damage", body: "You accidentally damaged a neighbor's fence while parking your car. They ask for compensation.", isMoneyOwed: true, amount: 150.00),
        WeeklyEvent(title: "Lost Wallet", body: "You lost your wallet with some cash inside. You cancel your cards to avoid further issues.", isMoneyOwed: true, amount: 50.00),
        WeeklyEvent(title: "Pet Emergency", body: "Your pet got sick and you had to rush them to the vet.", isMoneyOwed: true, amount: 200.00),
        WeeklyEvent(title: "Traffic Ticket", body: "You were caught speeding and now have to pay a fine.", isMoneyOwed: true, amount: 60.00),
        WeeklyEvent(title: "Car Accident", body: "You were involved in a minor accident, and now you’re dealing with insurance paperwork.", isMoneyOwed: true, amount: 150.00),
        WeeklyEvent(title: "Surprise Dinner", body: "Your partner invited you out for an unexpected dinner at a fancy restaurant.", isMoneyOwed: true, amount: 40.00),
        WeeklyEvent(title: "Annual Checkup", body: "You went to your yearly health checkup. Luckily, everything is fine.", isMoneyOwed: true, amount: 50.00),
        WeeklyEvent(title: "Movie Night", body: "You and your friends had a fun movie marathon at home with snacks and drinks. Although you had to pay for all the snacks and drinks", isMoneyOwed: true, amount: 60.00),
        WeeklyEvent(title: "Anniversary Celebration", body: "You celebrated your friends anniversary, although you had to spend a hefty amount of money on a gift.", isMoneyOwed: true, amount: 80.00),
        WeeklyEvent(title: "Unplanned Road Trip", body: "You decided to go on a spontaneous road trip and ended up spending a bit more than expected.", isMoneyOwed: true, amount: 250.00),
        WeeklyEvent(title: "Wedding Invitation", body: "You received an invitation to a friend’s wedding, which means you’ll need to buy a gift.", isMoneyOwed: true, amount: 100.00),
        WeeklyEvent(title: "Rooftop Bar", body: "You enjoyed a nice evening at a rooftop bar with some friends.", isMoneyOwed: true, amount: 60.00),
        WeeklyEvent(title: "Parking Fine", body: "You forgot to pay for parking, and now you have a fine to deal with.", isMoneyOwed: true, amount: 40.00),
    ]

    let superNegativeWeeklyEvents = [
        WeeklyEvent(title: "Computer Crash", body: "Your computer crashed unexpectedly, and you had to replace some components.", isMoneyOwed: true, amount: 400.00),
        WeeklyEvent(title: "Emergency Room Visit", body: "You had to visit the ER for a minor injury. It wasn’t serious, but the bill was hefty.", isMoneyOwed: true, amount: 500.00),
        WeeklyEvent(title: "Broken Appliance", body: "Your refrigerator broke down unexpectedly, and you had to replace it.", isMoneyOwed: true, amount: 600.00),
        WeeklyEvent(title: "Home Repairs", body: "You discovered a leak in your roof that needed immediate repair.", isMoneyOwed: true, amount: 700.00),
        WeeklyEvent(title: "Earthquake Damage", body: "Your area experienced an earthquake, and your home suffered some damage.", isMoneyOwed: true, amount: 800.00),
    ]

    let randomValue = Double.random(in: 0...1)
    
    if randomValue < 0.60 {
        return negativeWeeklyEvents.randomElement()
    } else if randomValue < 0.99 {
        return positiveWeeklyEvents.randomElement()
    } else {
        return superNegativeWeeklyEvents.randomElement()
    }
}
