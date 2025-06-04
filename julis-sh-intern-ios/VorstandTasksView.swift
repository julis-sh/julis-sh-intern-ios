import SwiftUI

struct VorstandTasksView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var taskVM = VorstandTaskViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SectionHeader(title: "Aufgaben")
                    .padding(.top, 8)
                if taskVM.isLoading {
                    ProgressView("Lade Aufgaben...")
                        .padding()
                } else if let error = taskVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if taskVM.plannerTasks.isEmpty && taskVM.todoTasks.isEmpty {
                    Text("Keine Aufgaben gefunden.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if !taskVM.plannerTasks.isEmpty {
                                Text("Zugewiesene Aufgaben (Planner)")
                                    .font(.headline)
                                    .padding(.leading)
                                ForEach(taskVM.plannerTasks) { task in
                                    TaskRow(title: task.title, dueDate: task.dueDate, completed: task.completed, listName: nil)
                                }
                            }
                            if !taskVM.todoTasks.isEmpty {
                                Text("Persönliche Aufgaben (To Do)")
                                    .font(.headline)
                                    .padding(.leading)
                                ForEach(Dictionary(grouping: taskVM.todoTasks, by: { $0.listName }).sorted(by: { $0.key < $1.key }), id: \ .key) { listName, tasks in
                                    Text(listName)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.accentColor)
                                        .padding(.leading, 8)
                                    ForEach(tasks) { task in
                                        TaskRow(title: task.title, dueDate: task.dueDate, completed: task.completed, listName: nil)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .refreshable {
                        if let token = loginViewModel.accessToken {
                            taskVM.fetchAllTasks(accessToken: token)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .background(Color("juliGrey").ignoresSafeArea())
            .navigationTitle("")
            .onAppear {
                if let token = loginViewModel.accessToken {
                    taskVM.fetchAllTasks(accessToken: token)
                }
            }
        }
    }
}

struct TaskRow: View {
    let title: String
    let dueDate: Date?
    let completed: Bool
    let listName: String?
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(completed ? .green : .secondary)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .font(.body.bold())
                        .strikethrough(completed, color: .secondary)
                        .foregroundColor(completed ? .secondary : .primary)
                    if completed {
                        StatusBadge(text: "Erledigt", color: .green)
                    } else if let due = dueDate, isOverdue(due) {
                        StatusBadge(text: "Überfällig", color: .red)
                    } else if let due = dueDate, isToday(due) {
                        StatusBadge(text: "Heute", color: .yellow)
                    }
                }
                if let due = dueDate {
                    Text("Fällig: \(formatDate(due))")
                        .font(.footnote)
                        .foregroundColor(isOverdue(due) && !completed ? .red : .secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(.secondarySystemBackground).opacity(completed ? 0.7 : 1.0))
        .cornerRadius(12)
        .shadow(color: Color(.black).opacity(0.03), radius: 2, y: 1)
        .padding(.vertical, 2)
    }
    func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateStyle = .medium
        return df.string(from: date)
    }
    func isOverdue(_ date: Date) -> Bool {
        date < Calendar.current.startOfDay(for: Date())
    }
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundColor(color == .yellow ? .black : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.85))
            .clipShape(Capsule())
    }
}

#Preview {
    VorstandTasksView().environmentObject(LoginViewModel())
} 