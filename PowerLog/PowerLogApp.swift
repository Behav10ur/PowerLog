import SwiftUI

@main
struct PowerLogApp: App {
    @AppStorage("hasSeenWelcomeScreen") private var hasSeenWelcomeScreen = false
    //@Binding var achievements: [Achievement]

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .sheet(isPresented: .constant(!hasSeenWelcomeScreen), onDismiss: {
                    hasSeenWelcomeScreen = true
                }) {
                    WelcomeView()
                }
        }
    }
}
