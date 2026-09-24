import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasSeenWelcomeScreen") private var hasSeenWelcomeScreen = false

    var body: some View {
        VStack(spacing: 5) {
            Text("Добро пожаловать")
                .font(.largeTitle)
                .padding()
                .bold()
            HStack {
                Text("в").bold().font(.largeTitle)
                Text("PowerLog")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding(.bottom, 50)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Label("Создание своих тренировок", systemImage: "figure.run")
                Text("Создавайте свои тренировки или выбирайте из готовых шаблонов для различных групп мышц и уровней подготовки.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label("Запись и анализ результатов", systemImage: "highlighter")
                Text("Записывайте вес, количество повторений, время выполнения и другие важные параметры для каждого упражнения.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label("Мотивация и цели", systemImage: "trophy")
                Text("Отслеживайте свои личные рекорды  и ставьте новые цели.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                hasSeenWelcomeScreen = true
            }) {
                Text("Продолжить")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
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
        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
