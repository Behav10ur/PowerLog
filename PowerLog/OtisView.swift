import SwiftUI

class ClaudeAPI {
    let apiKey = ""
    let baseURL = ""

    func sendMessage(userMessage: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        
        let requestData: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1000,
            "temperature": 0,
            "system": "You are a world-class fitness-coach.",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": userMessage
                        ]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = jsonResponse["choices"] as? [[String: Any]],
                   let content = message.first?["text"] as? String {
                    completion(content)
                } else {
                    completion(nil)
                }
            } catch {
                print("Parsing error: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}

struct OtisView: View {
    @State private var userMessage: String = ""
    @State private var assistantResponse: String = ""
    @State private var isLoading: Bool = false
    @State private var messages: [Message] = [
        Message(text: "Привет, я - Отис, твой персональный помощник!", isUser: false)
    ]
    
    let api = ClaudeAPI()

    func sendMessage() {
        guard !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isLoading = true
        
        messages.append(Message(text: userMessage, isUser: true))
        
        api.sendMessage(userMessage: userMessage) { response in
            DispatchQueue.main.async {
                self.assistantResponse = response ?? "Ошибка при получении ответа"
                self.isLoading = false
                
                self.messages.append(Message(text: self.assistantResponse, isUser: false))
                
                self.userMessage = ""
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding()
                }
                
                HStack {
                    TextField("Введите вопрос", text: $userMessage)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 25))
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                }
                .navigationTitle("Помощник Отис")
            }
        }
    }

}
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(0.8)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                Spacer()
            }
        }
    }
}

struct Otis_Previews: PreviewProvider {
    static var previews: some View {
        OtisView()
    }
}
