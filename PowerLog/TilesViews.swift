import SwiftUI
import Charts

struct WorkoutTileView: View {
    var activity: Activity
    var onEdit: () -> Void

    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(activity.title)")
                            .font(.system(size: 16))
                        
                        Text("Цель: \(activity.goal, specifier: "%.1f")")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Text("\(activity.amount, specifier: "%.1f")")
                    .font(.system(size: 24))
                
                ProgressView(value: activity.amount, total: activity.goal)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.purple)
                    .frame(height: 8)
                    .cornerRadius(15)
                
                Button(action: onEdit) {
                    Text("Изменить")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(width: 120, height: 130)
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(15)
    }
}

struct BarTileView: View {
    var activities: [Activity]
        
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            VStack {
                Text("Прогресс за день")
                    .font(.headline)
                
                Chart(activities) { activity in
                    BarMark(
                        x: .value("Упражнение", activity.title),
                        y: .value("Прогресс", min(activity.amount / activity.goal, 2.0))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    
                    RuleMark(y: .value("Цель", 1.0))
                        .foregroundStyle(Color.cyan)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisValueLabel()
                    }
                }
            }
            .padding()
            .cornerRadius(15)
        }
        .frame(width: 340)
    }
}

struct AchievementTile: View {
    @Binding var achievement: Achievement
    var onTap: () -> Void
    
    var progressFraction: Double {
        min(Double(achievement.progress) / Double(achievement.goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Цель: \(achievement.goal, specifier: "%.1f")")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(achievement.isCompleted ? .green : .gray)
                
                Circle()
                    .trim(from: 0.0, to: progressFraction)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(achievement.isCompleted ? .green : .purple)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: progressFraction)
                
                Text("\(achievement.progress, specifier: "%.1f")")
                    .font(.title2)
                    .bold()
            }
            .frame(width: 100, height: 100)
        }
        .frame(width: 140, height: 160)
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(achievement.isCompleted ? Color.green : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
}
