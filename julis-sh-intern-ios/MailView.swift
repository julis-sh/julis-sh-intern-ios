import SwiftUI

struct MailView: View {
    @StateObject private var viewModel = MailViewModel()
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var fieldErrors: [String: String] = [:]
    
    // Szenario → relevante Felder (wie im Web)
    let szenarioFelder: [String: [String]] = [
        "eintritt": ["vorname", "nachname", "email", "strasse", "hausnummer", "plz", "ort", "telefon", "kreis", "geburtsdatum", "eintrittsdatum", "mitgliedsnummer"],
        "austritt": ["vorname", "nachname", "email", "kreis", "austrittsdatum", "mitgliedsnummer"],
        "veraenderung": ["vorname", "nachname", "strasse", "hausnummer", "plz", "ort", "telefon", "email", "kreis", "mitgliedsnummer"],
        "verbandswechsel_eintritt": ["vorname", "nachname", "strasse", "hausnummer", "plz", "ort", "telefon", "email", "geburtsdatum", "kreis_neu", "eintrittsdatum", "mitgliedsnummer"],
        "verbandswechsel_austritt": ["vorname", "nachname", "email", "kreis_alt", "austrittsdatum", "mitgliedsnummer"],
        "verbandswechsel_intern": ["vorname", "nachname", "email", "kreis_alt", "kreis_neu", "mitgliedsnummer"]
    ]
    let datumsfelder = ["geburtsdatum", "eintrittsdatum", "austrittsdatum"]
    let steps: [(label: String, fields: [String])] = [
        ("Persönliche Daten", ["vorname", "nachname", "geschlecht", "geburtsdatum"]),
        ("Adresse", ["strasse", "hausnummer", "plz", "ort"]),
        ("Kontakt", ["email", "telefon"]),
        ("Mitgliedschaft", ["kreis", "kreis_neu", "kreis_alt", "mitgliedsnummer", "eintrittsdatum", "austrittsdatum"])
    ]
    let geschlechtOptionen = [("", "Bitte wählen"), ("m", "Männlich"), ("w", "Weiblich"), ("d", "Divers")]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    SectionHeader(title: "Mail versenden")
                        .padding(.top, 8)
                    VStack(spacing: 20) {
                        SectionHeader(title: "Szenario")
                        Picker("Szenario", selection: $viewModel.selectedScenario) {
                            Text("Bitte wählen").tag(MailScenario?.none)
                            ForEach(viewModel.scenarios) { s in
                                Text(s.label).tag(Optional(s))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                        .background(Color("juliGrey"))
                        .cornerRadius(12)
                        .shadow(color: Color("juliBlack").opacity(0.06), radius: 4, y: 2)
                        if let scenario = viewModel.selectedScenario?.value, let felder = szenarioFelder[scenario] {
                            VStack(spacing: 16) {
                                ForEach(steps.flatMap { $0.fields }.filter { felder.contains($0) }, id: \.self) { feld in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 4) {
                                            Text(feld.capitalized + (feld == "email" || feld == "vorname" || feld == "nachname" ? " *" : ""))
                                                .font(.subheadline.bold())
                                                .foregroundColor(Color(.label))
                                            if let err = fieldErrors[feld] {
                                                Text(err).foregroundColor(Color("juliRed")).font(.caption)
                                            }
                                        }
                                        if feld == "geschlecht" {
                                            Picker("Geschlecht", selection: Binding(
                                                get: { (viewModel.mitglied[feld] as? String) ?? "" },
                                                set: { viewModel.mitglied[feld] = $0 }
                                            )) {
                                                ForEach(geschlechtOptionen, id: \.0) { val, label in
                                                    Text(label).tag(val)
                                                }
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                        } else if feld == "kreis" || feld == "kreis_neu" || feld == "kreis_alt" {
                                            Picker(feld.capitalized, selection: Binding(
                                                get: { (viewModel.mitglied[feld] as? String) ?? "" },
                                                set: { viewModel.mitglied[feld] = $0 }
                                            )) {
                                                Text("Bitte wählen").tag("")
                                                ForEach(viewModel.kreise, id: \.id) { k in
                                                    Text(k.name).tag(String(k.id))
                                                }
                                            }
                                        } else if datumsfelder.contains(feld) {
                                            DatePicker(feld.capitalized, selection: Binding(
                                                get: {
                                                    if let str = viewModel.mitglied[feld] as? String, let date = ISO8601DateFormatter().date(from: str) { return date }
                                                    return Date()
                                                },
                                                set: {
                                                    if feld == "eintrittsdatum" {
                                                        let df = DateFormatter()
                                                        df.dateFormat = "yyyy-MM-dd"
                                                        viewModel.mitglied[feld] = df.string(from: $0)
                                                    } else {
                                                        viewModel.mitglied[feld] = ISO8601DateFormatter().string(from: $0)
                                                    }
                                                }
                                            ), displayedComponents: .date)
                                        } else {
                                            TextField(feld.capitalized, text: Binding(
                                                get: { (viewModel.mitglied[feld] as? String) ?? "" },
                                                set: { viewModel.mitglied[feld] = $0 }
                                            ))
                                            .autocapitalization(.none)
                                            .keyboardType(feld == "email" ? .emailAddress : .default)
                                            .padding(10)
                                            .background(Color("juliGrey"))
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("juliYellow"), lineWidth: 2))
                                        }
                                    }
                                }
                                Button(action: senden) {
                                    if viewModel.isSending {
                                        ProgressView()
                                    } else {
                                        Text("Mails versenden")
                                            .font(.headline.bold())
                                            .foregroundColor(Color(.label))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color("juliYellow"))
                                            .cornerRadius(14)
                                            .shadow(color: Color("juliYellow").opacity(0.18), radius: 8, y: 4)
                                    }
                                }
                                .disabled(viewModel.isSending || !allePflichtfelderGueltig(felder))
                            }
                            .padding()
                            .background(Color("juliGrey"))
                            .cornerRadius(18)
                            .shadow(color: Color("juliBlack").opacity(0.06), radius: 10, y: 4)
                        } else {
                            Text("Bitte wähle ein Szenario aus.")
                                .foregroundColor(Color(.label).opacity(0.5))
                                .padding()
                        }
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(Color("juliRed"))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color("juliGrey").ignoresSafeArea())
            .navigationTitle("")
            .onAppear {
                viewModel.loadData()
            }
            .onChange(of: viewModel.selectedScenario) { _ in }
            .onChange(of: viewModel.successMessage) { msg in
                if let msg = msg {
                    toastMessage = msg
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showToast = false
                        viewModel.successMessage = nil
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
    
    func senden() {
        if let scenario = viewModel.selectedScenario?.value, let felder = szenarioFelder[scenario], !allePflichtfelderGueltig(felder) { return }
        viewModel.sendMail { _ in }
    }
    
    func allePflichtfelderGueltig(_ felder: [String]) -> Bool {
        fieldErrors = [:]
        var allesOk = true
        for feld in felder {
            let wert = (viewModel.mitglied[feld] as? String) ?? ""
            if wert.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fieldErrors[feld] = "Pflichtfeld"
                allesOk = false
            } else if feld == "email" && !isValidEmail(wert) {
                fieldErrors[feld] = "Ungültige E-Mail-Adresse"
                allesOk = false
            }
        }
        return allesOk
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    MailView()
} 