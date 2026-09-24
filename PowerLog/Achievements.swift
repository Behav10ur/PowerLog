import SwiftUI

struct Achievement: Identifiable, Encodable, Decodable {
    var id = UUID()
    let title: String
    let goal: Double
    var progress: Double
    var isCompleted: Bool {
        progress >= goal
    }
}

struct AchievementsView: View {
    
    func saveAchievements() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(achievements)
            UserDefaults.standard.set(data, forKey: "achievements")
        } catch {
            print("Ошибка при сохранении достижений: \(error)")
        }
    }
        
    func loadAchievements() {
        do {
            if let data = UserDefaults.standard.data(forKey: "achievements") {
                let decoder = JSONDecoder()
                achievements = try decoder.decode([Achievement].self, from: data)
            }
        } catch {
            print("Ошибка при загрузке достижений: \(error)")
        }
    }
    
    func updateLinkedAchievements(for updatedAchievement: Achievement) {
        for index in achievements.indices {
            if achievements[index].title.contains(updatedAchievement.title.components(separatedBy: " ")[0]) {
                achievements[index].progress = updatedAchievement.progress
            }
        }
        saveAchievements()
    }
    
    @State private var achievements: [Achievement] = [
        Achievement(title: "Отжимания 1", goal: 50, progress: 0),
        Achievement(title: "Приседания 1", goal: 75, progress: 0),
        Achievement(title: "Бег 1", goal: 10, progress: 0),
        Achievement(title: "Жим стоя 1", goal: 100, progress: 0),
        Achievement(title: "Подтягивания 1", goal: 35, progress: 0),
        Achievement(title: "Ходьба 1", goal: 12000, progress: 0),
        Achievement(title: "Прыжки 1", goal: 150, progress: 0),
        Achievement(title: "Становая тяга 1", goal: 100, progress: 0),
        Achievement(title: "Отжимания 2", goal: 75, progress: 0),
        Achievement(title: "Приседания 2", goal: 100, progress: 0),
        Achievement(title: "Бег 2", goal: 20, progress: 0),
        Achievement(title: "Жим стоя 2", goal: 130, progress: 0),
        Achievement(title: "Подтягивания 2", goal: 50, progress: 0),
        Achievement(title: "Ходьба 2", goal: 20000, progress: 0),
        Achievement(title: "Прыжки 2", goal: 200, progress: 0),
        Achievement(title: "Становая тяга 2", goal: 150, progress: 0)
    ]
    
    @State private var selectedAchievement: Achievement?
    
    init() {
           loadAchievements()
       }
    
    var body: some View {
        NavigationStack {
            Spacer(minLength: 15)
            ScrollView {
                VStack {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach($achievements) { $achievement in
                            AchievementTile(achievement: $achievement) {
                                selectedAchievement = achievement
                            }
                        }
                    }
                }
                .navigationTitle("Достижения")
            }
            .sheet(item: $selectedAchievement) { achievement in
                EditProgressView(
                    achievement: $achievements[achievements.firstIndex(where: { $0.id == achievement.id })!],
                    onSave: { updatedAchievement in
                        if let index = achievements.firstIndex(where: { $0.id == updatedAchievement.id }) {
                            achievements[index] = updatedAchievement
                            updateLinkedAchievements(for: updatedAchievement)
                        }
                        saveAchievements()
                    }
                )
            }
        }
        .onAppear {
            loadAchievements()
        }
        .onDisappear {
            saveAchievements()
        }
    }
}

struct EditProgressView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var achievement: Achievement
    var onSave: (Achievement) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Редактирование")) {
                    Text(achievement.title)
                        .font(.headline)
                        .padding(.vertical, 5)
                }
                
                Section(header: Text("Цель")) {
                    Text("Цель: \(achievement.goal, specifier: "%.1f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Текущий прогресс")) {
                    TextField("Введите прогресс", value: $achievement.progress, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Редактировать достижение")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(achievement)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
