import SwiftUI

struct UserFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String
    @State private var role: String
    @State private var password: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    let isEdit: Bool
    let onSave: (String, String, String) -> Void
    
    let roles = [
        (value: "admin", label: "Admin"),
        (value: "lgst", label: "Landesgeschäftsstelle"),
        (value: "vorstand", label: "Landesvorstand"),
        (value: "user", label: "User")
    ]
    
    init(email: String = "", role: String = "", isEdit: Bool = false, onSave: @escaping (String, String, String) -> Void) {
        _email = State(initialValue: email)
        _role = State(initialValue: role)
        self.isEdit = isEdit
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("juliGrey").ignoresSafeArea()
                VStack(spacing: 24) {
                    SectionHeader(title: isEdit ? "Benutzer bearbeiten" : "Benutzer anlegen")
                        .padding(.top, 8)
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("E-Mail *")
                                .font(.subheadline.bold())
                                .foregroundColor(Color(.label))
                            TextField("E-Mail", text: $email)
                                .padding(12)
                                .background(Color("juliGrey"))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("juliYellow"), lineWidth: 2))
                                .autocapitalization(.none)
                                .disabled(isEdit)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Rolle *")
                                .font(.subheadline.bold())
                                .foregroundColor(Color(.label))
                            Picker("Rolle", selection: $role) {
                                ForEach(roles, id: \ .value) { r in
                                    Text(r.label).tag(r.value)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isEdit ? "Neues Passwort (optional)" : "Passwort *")
                                .font(.subheadline.bold())
                                .foregroundColor(Color(.label))
                            SecureField(isEdit ? "Neues Passwort (optional)" : "Passwort", text: $password)
                                .padding(12)
                                .background(Color("juliGrey"))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("juliYellow"), lineWidth: 2))
                        }
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(Color("juliRed"))
                                .font(.footnote)
                        }
                        Button(action: save) {
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Speichern")
                                    .font(.headline.bold())
                                    .foregroundColor(Color(.label))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("juliYellow"))
                                    .cornerRadius(14)
                                    .shadow(color: Color("juliYellow").opacity(0.18), radius: 8, y: 4)
                            }
                        }
                        .disabled(isSaving)
                    }
                    .padding()
                    .background(Color("juliGrey"))
                    .cornerRadius(18)
                    .shadow(color: Color("juliBlack").opacity(0.06), radius: 10, y: 4)
                    Spacer()
                }
                .padding()
                if isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack {
                        ProgressView("Speichern...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func save() {
        errorMessage = nil
        // E-Mail Validierung
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "E-Mail darf nicht leer sein."
            return
        }
        if !isValidEmail(email) {
            errorMessage = "Bitte gib eine gültige E-Mail-Adresse ein."
            return
        }
        if role.isEmpty {
            errorMessage = "Bitte wähle eine Rolle."
            return
        }
        if !isEdit && password.count < 6 {
            errorMessage = "Passwort muss mindestens 6 Zeichen lang sein."
            return
        }
        isSaving = true
        onSave(email, role, password)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    UserFormView(email: "", role: "", isEdit: false) { _,_,_ in }
} 