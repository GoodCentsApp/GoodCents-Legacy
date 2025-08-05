import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
//            TabMainView()
//                .modelContainer(for: [Player.self, Time.self, Transactions.self, OwnedItems.self, Job.self, CompletedLessons.self])
//                .fontDesign(.rounded)
            VStack {
                Spacer()
                
                Text("GoodCents has now moved to the App Store!")
                    .font(.title)
                    .bold()
                    .padding()
                
                Text("Please download the latest version from the App Store to continue enjoying the app.")
                    .padding()
                
                Text("Thank you all for your support and downloading GoodCents! <3")
                
                Spacer()
                
                Button(action: {
                    if let url = URL(string: "https://apps.apple.com/app/goodcents/id6745572331") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Download from App Store")
                        .font(.title2)
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .fontDesign(.rounded)
        }
    }
}
