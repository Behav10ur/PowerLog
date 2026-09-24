//import SwiftUI
//
//class ActivityManager: ObservableObject {
//    @Published var activitiesByDay: [Date: [Activity]] = [:]
//    @Published var achievements: [Achievement] = []
//    
//    @AppStorage("activitiesByDay") private var storedActivitiesByDay: Data = Data()
//    @AppStorage("achievements") private var storedAchievements: Data = Data()
//    
//    init() {
//        loadActivities()
//        loadAchievements()
//    }
//    
//    func saveActivities() {
//        do {
//            let encodedData = try JSONEncoder().encode(activitiesByDay)
//            UserDefaults.standard.set(encodedData, forKey: "activitiesByDay")
//        } catch {
//            print("Ошибка сохранения данных: \(error)")
//        }
//    }
//    
//    func loadActivities() {
//        guard let data = UserDefaults.standard.data(forKey: "activitiesByDay") else { return }
//        do {
//            activitiesByDay = try JSONDecoder().decode([Date: [Activity]].self, from: data)
//        } catch {
//            print("Ошибка загрузки данных: \(error)")
//        }
//    }
//    
//    func saveAchievements() {
//        do {
//            let encoded = try JSONEncoder().encode(achievements)
//            UserDefaults.standard.set(encoded, forKey: "achievements")
//        } catch {
//            print("Ошибка сохранения достижений: \(error)")
//        }
//    }
//    
//    func loadAchievements() {
//        guard let data = UserDefaults.standard.data(forKey: "achievements") else { return }
//        do {
//            achievements = try JSONDecoder().decode([Achievement].self, from: data)
//        } catch {
//            print("Ошибка загрузки достижений: \(error)")
//        }
//    }
//    
//    func addActivity(for date: Date, activity: Activity) {
//        let normalizedDate = Calendar.current.startOfDay(for: date)
//        if activitiesByDay[normalizedDate] == nil {
//            activitiesByDay[normalizedDate] = []
//        }
//        activitiesByDay[normalizedDate]?.append(activity)
//        saveActivities()
//        updateAchievements(with: activity)
//    }
//    
//    func updateAchievements(with activity: Activity) {
//        if let index = achievements.firstIndex(where: { $0.title + " 1" == activity.title || $0.title + " 2" == activity.title }) {
//            achievements[index].progress = max(achievements[index].progress, Int(activity.amount))
//            saveAchievements()
//        }
//    }
//}
