//
//  Templates.swift
//  GoodCents
//
//  Created by GoodCents on 11/20/24.
//

import SwiftUI
import SwiftData
import Confetti

// MARK: -Feature Point View (Used in Welcome Screen)
struct FeaturePointView: View {
    var title: String = "Title"
    var subTitle: String = "Subtitle"
    var imageName: String = "timer"
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundStyle(.blue)
                .font(.largeTitle)
                .padding()
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subTitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

// MARK: -Title, Symbol and Subtitle header for sheets/full screen views
struct SheetHeader: View {
    var imageName: String
    var title: String
    var subtitle: String
    var backgroundColor: Color = .clear
    var isCustomImage: Bool = false

    var body: some View {
        VStack(spacing: 5) {
            if !isCustomImage {
                Image(systemName: imageName)
                    .font(.system(size: 95))
                    .foregroundStyle(.white)
                    .frame(width: 114, height: 114)
                    .background(backgroundColor)
                    .cornerRadius(20)
                    .padding(.bottom, 5)
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 114, height: 114)
                    .cornerRadius(20)
                    .padding(.bottom, 5)
            }
            
            Text(title)
                .font(.title)
                .bold()

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top)
    }
}

// MARK: -List Item used for bank account, purchase items etc
struct ListItem<T: BinaryFloatingPoint & CustomStringConvertible>: View {
    var icon: String
    var title: String
    var playerVar: KeyPath<Player, T>?
    var players: [Player]?
    var isAccount: Bool = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                )
                .padding(.trailing, 5)
            
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .font(.title2)
                
                if let player = players?.first, let playerVar = playerVar {
                    Text(player[keyPath: playerVar], format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                } else if players?.isEmpty == false {
                    Text("No player found")
                }
            }
        }
    }
}

// MARK: -Horizontal List Item (Used in Horizontal Scroll Views)
struct HorizontalListItem<T: BinaryFloatingPoint & CustomStringConvertible>: View {
    var icon: String
    var title: String
    var playerVar: KeyPath<Player, T>?
    var players: [Player]?
    var isAccount: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 125, height: 125)
                .foregroundStyle(.clear)
            
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 80, height: 80)
                    )
                    .clipShape(Circle())
                
                HStack {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.top, 2)
                }
                
                if let player = players?.first, let playerVar = playerVar {
                    Text(player[keyPath: playerVar], format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                } else if players?.isEmpty == false {
                    Text("No player found")
                }
            }
        }
        .compositingGroup()
    }
}

// MARK: -Line Element
@ViewBuilder
func Line() -> some View {
    RoundedRectangle(cornerRadius: 4)
        .foregroundStyle(.tertiary)
        .frame(height: 1)
        .opacity(0.5)
        .padding(.vertical, 0.1)
}

// MARK: -Circular Progress View
struct CircularProgressView: View {
    var progress: Double
    var lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.primary.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: -Confetti Spam!!!
struct ConfettiSpam: View {
    @Binding var showConfetti: Bool
    let emissionDuration: Double
    
    var body: some View {
        ZStack {
            ConfettiView(emissionDuration: emissionDuration)
            ConfettiView(emissionDuration: emissionDuration)
            ConfettiView(emissionDuration: emissionDuration)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                showConfetti = false
            }
        }
    }
}

// MARK: -Owned Item List Item
struct OwnedItemListItem: View {
    let item: OwnedItems
    let player: Player
    @Binding var selectedItem: OwnedItems?
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.secondary.opacity(selectedItem?.itemName == item.itemName ? 0.01 : 0.00))
                .frame(height: selectedItem?.itemName == item.itemName ? item.itemIsSellable ? 135 : 105 : 70)
            
            VStack {
                HStack {
                    Image(systemName: item.itemIcon)
                        .font(.system(size: 26))
                        .frame(width: 43, height: 43)
                        .foregroundStyle(.white)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 43, height: 43)
                        )
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(item.itemName)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        Text("Paid: \(item.itemPrice, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(selectedItem?.itemName == item.itemName ? 90 : 0))
                        .foregroundStyle(.gray)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.top, 2)
                }
                .onTapGesture {
                    withAnimation(.smooth(duration: 0.25, extraBounce: 0)) {
                        if selectedItem?.itemName == item.itemName {
                            selectedItem = nil
                        } else {
                            selectedItem = item
                        }
                    }
                }
                
                
                if selectedItem?.itemName == item.itemName {
                    Line()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Quantity: \(item.itemQuantity)")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                                    .opacity(selectedItem?.itemName == item.itemName ? 1 : 0)
                                
                                if item.itemIsSellable {
                                    Text("Resale Value: \(item.itemValue, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                        .opacity(selectedItem?.itemName == item.itemName ? 1 : 0)
                                }
                            }
                            
                            if item.itemIsSellable {
                                Spacer()
                                
                                Text("Sell Item")
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.blue)
                                    )
                                    .onTapGesture {
                                        sellItem(
                                            item: item,
                                            player: player,
                                            modelContext: modelContext
                                        )
                                    }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
    HorizontalListItem<Double>(
        icon: "square",
        title: "Clothing"
    )
}
