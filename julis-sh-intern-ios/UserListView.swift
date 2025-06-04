import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    @State private var showForm = false
    @State private var editUser: User? = nil
    @State private var showDeleteAlert = false
    @State private var deleteUser: User? = nil
    @State private var searchText: String = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SectionHeader(title: "Benutzerverwaltung")
                    .padding(.top, 8)
                HStack {
                    TextField("Suche nach E-Mail oder Rolle", text: $searchText)
                        .padding(12)
                        .background(Color("juliGrey"))
                        .cornerRadius(12)
                        .shadow(color: Color("juliBlack").opacity(0.06), radius: 4, y: 2)
                        .padding(.horizontal)
                        .foregroundColor(Color(.label))
                    Button(action: {
                        editUser = nil
                        showForm = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundColor(Color("juliBlack"))
                            .padding(10)
                            .background(Color("juliYellow"))
                            .clipShape(Circle())
                            .shadow(color: Color("juliYellow").opacity(0.18), radius: 6, y: 2)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 8)
                if viewModel.isLoading {
                    ProgressView("Lade Benutzer...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Color("juliRed"))
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.users.filter { user in
                                searchText.isEmpty ||
                                user.email.localizedCaseInsensitiveContains(searchText) ||
                                user.role.localizedCaseInsensitiveContains(searchText)
                            }) { user in
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.email)
                                            .font(.headline)
                                            .foregroundColor(Color(.label))
                                        Text("Rolle: \(roleLabel(user.role))")
                                            .font(.subheadline)
                                            .foregroundColor(Color(.label).opacity(0.7))
                                    }
                                    Spacer()
                                    Button(action: {
                                        editUser = user
                                        showForm = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(Color("juliTurquoise"))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    Button(action: {
                                        deleteUser = user
                                        showDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(Color("juliRed"))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding()
                                .background(Color("juliGrey"))
                                .cornerRadius(16)
                                .shadow(color: Color("juliBlack").opacity(0.06), radius: 8, y: 4)
                            }
                            if viewModel.users.isEmpty {
                                Text("Keine Benutzer vorhanden.")
                                    .foregroundColor(Color(.label).opacity(0.5))
                                    .padding()
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color("juliGrey").ignoresSafeArea())
            .sheet(isPresented: $showForm) {
                Group {
                    if let user = editUser {
                        UserFormView(email: user.email, role: user.role, isEdit: true) { email, role, password in
                            viewModel.updateUser(id: user.id, role: role, password: password.isEmpty ? nil : password) { success in
                                showForm = false
                            }
                        }
                    } else {
                        UserFormView(isEdit: false) { email, role, password in
                            viewModel.createUser(email: email, role: role, password: password) { success in
                                showForm = false
                            }
                        }
                    }
                }
                .onDisappear {
                    editUser = nil
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Benutzer löschen?"),
                    message: Text("Möchtest du diesen Benutzer wirklich löschen?"),
                    primaryButton: .destructive(Text("Löschen")) {
                        if let user = deleteUser {
                            viewModel.deleteUser(id: user.id) { _ in }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                viewModel.fetchUsers()
            }
            .onChange(of: viewModel.showSuccess) { newValue in
                if newValue {
                    toastMessage = viewModel.successMessage
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showToast = false
                        viewModel.showSuccess = false
                    }
                }
            }
            .overlay(
                ToastView(message: toastMessage)
                    .opacity(showToast ? 1 : 0)
                    .animation(.easeInOut, value: showToast)
                    .padding(.bottom, 40), alignment: .bottom
            )
        }
    }
    
    func roleLabel(_ role: String) -> String {
        switch role {
        case "admin": return "Admin"
        case "lgst": return "Landesgeschäftsstelle"
        case "vorstand": return "Landesvorstand"
        case "user": return "User"
        default: return role
        }
    }
}

#Preview {
    UserListView()
} 