import SwiftUI
import Charts

struct MainView: View {

    @State private var currentWeek: [Date] = []
    @State private var currentDay: Date = Date()
    //@Binding var achievements: [Achievement]

    @AppStorage("activitiesByDay") private var storedActivitiesByDay: Data = Data()
    @State private var activitiesByDay: [Date: [Activity]] = [:]
    
    @State private var isAddWorkoutPresented = false
    @State private var selectedActivity: Activity? = nil
    @State private var isEditWorkoutPresented = false
    
    
    
    func saveActivities() {
        do {
            let encodedData = try JSONEncoder().encode(activitiesByDay)
            UserDefaults.standard.set(encodedData, forKey: "activitiesByDay")
        } catch {
            print("Ошибка сохранения данных: \(error)")
        }
    }

    func loadActivities() {
        guard let data = UserDefaults.standard.data(forKey: "activitiesByDay") else { return }
        do {
            activitiesByDay = try JSONDecoder().decode([Date: [Activity]].self, from: data)
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    func extractCurrentWeek() {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: Date())
        
        guard let firstDay = week?.start else { return }
        currentWeek = []
        
        (0..<7).forEach { day in
            if let weekDay = calendar.date(byAdding: .day, value: day, to: firstDay) {
                if !currentWeek.contains(weekDay) {
                    currentWeek.append(weekDay)
                }
            }
        }
    }
    
    func extractDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = (isSameDay(date1: currentDay, date2: date) ? "dd EE" : "dd")
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    func addActivity(for date: Date, activity: Activity) {
        let normalizedDate = normalizeDate(date)
        if activitiesByDay[normalizedDate] == nil {
            activitiesByDay[normalizedDate] = []
        }
        activitiesByDay[normalizedDate]?.append(activity)
        saveActivities()
    }

    func removeActivity(for date: Date, activity: Activity) {
        let normalizedDate = normalizeDate(date)
        activitiesByDay[normalizedDate]?.removeAll { $0.id == activity.id }
        saveActivities()
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(spacing: 10) {
                    ForEach(currentWeek, id: \.self) { date in
                        Text(extractDate(date: date))
                            .fontWeight(isSameDay(date1: currentDay, date2: date) ? .bold : .semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isSameDay(date1: currentDay, date2: date) ? 6 : 0)
                            .padding(.horizontal, isSameDay(date1: currentDay, date2: date) ? 12 : 0)
                            .frame(width: isSameDay(date1: currentDay, date2: date) ? 100 : nil)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .environment(\.colorScheme, .light)
                                    .opacity(isSameDay(date1: currentDay, date2: date) ? 0.8 : 0)
                            )
                            .onTapGesture {
                                withAnimation {
                                    currentDay = date
                                }
                            }
                    }
                }
                .onAppear {
                    extractCurrentWeek()
                    loadActivities()
                }
                
                Spacer(minLength: 30)
                
                VStack {
                    let normalizedDate = normalizeDate(currentDay)
                    if let activities = activitiesByDay[normalizedDate], !activities.isEmpty {
                        BarTileView(activities: activities)
                        
                        Spacer(minLength: 10)
                        
                        ScrollView {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 20
                            ) {
                                ForEach(activities) { activity in
                                    WorkoutTileView(activity: activity) {
                                        selectedActivity = activity
                                        isEditWorkoutPresented = true
                                    }
                                }
                            }
                            .padding()
                        }
                    } else {
                        Text("Нет упражнений для выбранного дня")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .navigationTitle(Text("Главный экран"))
                
                .sheet(isPresented: $isEditWorkoutPresented) {
                    if let selectedActivity {
                        EditWorkout(
                            activity: selectedActivity,
                            onSave: { updatedActivity in
                                let normalizedDate = normalizeDate(currentDay)
                                if let index = activitiesByDay[normalizedDate]?.firstIndex(where: { $0.id == updatedActivity.id }) {
                                    activitiesByDay[normalizedDate]?[index] = updatedActivity
                                    saveActivities()
                                }
                            },
                            onDelete: { activityToDelete in
                                removeActivity(for: currentDay, activity: activityToDelete)
                            }
                        )
                    }
                }
                
                Button(action: {
                    isAddWorkoutPresented.toggle()
                }) {
                    Text("Добавить упражнение")
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding()
                .sheet(isPresented: $isAddWorkoutPresented) {
                    AddWorkout() { newActivity in
                        addActivity(for: currentDay, activity: newActivity)
                    }
                }
            }
        }
    }
}

struct Activity: Identifiable, Codable {
    let id: Int
    var goal: Double
    let title: String
    var amount: Double
}

struct AddWorkout: View {
    @Environment(\.dismiss) var dismiss
    
    let exerciseNames = ["Подтягивания", "Жим стоя", "Приседания", "Ходьба", "Отжимания", "Прыжки", "Становая тяга"]
    //@Binding var achievements: [Achievement]
    
    @State private var selectedExercise: String? = nil
    @State private var customExerciseName: String = ""
    @State private var isCustomExercise = false
    @State private var goal: Double = 0
    @State private var amount: Double = 0
        
    var onSaveActivity: (Activity) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Выбор упражнения")) {
                    Menu {
                        ForEach(exerciseNames, id: \.self) { exercise in
                            Button(action: {
                                selectedExercise = exercise
                                isCustomExercise = false
                            }) {
                                Text(exercise)
                            }
                        }
                        
                        Button(action: {
                            selectedExercise = nil
                            isCustomExercise = true
                        }) {
                            Text("Другое")
                        }
                    } label: {
                        Text(selectedExercise ?? (isCustomExercise ? customExerciseName : "Выберите упражнение"))
                            .foregroundColor(.blue)
                    }
                    
                    if isCustomExercise {
                        TextField("Введите название упражнения", text: $customExerciseName)
                            .onChange(of: customExerciseName) { newValue in
                                selectedExercise = newValue
                            }
                    }
                }
                
                Section(header: Text("Установка цели")) {
                    TextField("Цель", value: $goal, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Текущее количество")) {
                    TextField("Текущий показатель", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Добавление")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let finalTitle = isCustomExercise ? customExerciseName : (selectedExercise ?? "Неизвестное упражнение")
                        let newActivity = Activity(id: UUID().hashValue, goal: goal, title: finalTitle, amount: amount)
                        
//                        if let index = achievements.firstIndex(where: { $0.title == finalTitle + " 1" }) {
//                            achievements[index].progress = max(achievements[index].progress, newActivity.amount)
//                        }
                        
                        onSaveActivity(newActivity)
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

struct EditWorkout: View {
    @Environment(\.dismiss) var dismiss
    @State var activity: Activity
    var onSave: (Activity) -> Void
    var onDelete: (Activity) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Редактирование")) {
                    Text(activity.title)
                        .font(.headline)
                }
                
                Section(header: Text("Установка цели")) {
                    TextField("Цель", value: $activity.goal, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Текущее количество")) {
                    TextField("Текущий показатель", value: $activity.amount, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Редактировать упражнение")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(activity)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    onDelete(activity)
                    dismiss()
                }) {
                    Text("Удалить упражнение")
                }
                .buttonStyle(.bordered)
                .cornerRadius(25)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .foregroundColor(.red)
            }
        }
    }
}
//struct MainWindow_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView(achievements: $achievements)
//    }
//}
