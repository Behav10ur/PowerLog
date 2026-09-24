import SwiftUI

struct MainTabView: View {
    //@Binding var achievements: [Achievement]
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Сводка", systemImage: "house")
                        .padding()
                }
            
            OtisView()
                .tabItem {
                    Label("Отис", systemImage: "ellipsis.message")
                        .padding()
                }
            
            AchievementsView()
                .tabItem {
                    Label("Достижения", systemImage: "trophy.fill")
                        .padding()
                }
        }
        .accentColor(.purple)
    }
}
