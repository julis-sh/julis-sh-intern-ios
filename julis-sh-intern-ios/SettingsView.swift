import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = "de"
    @AppStorage("themeMode") private var themeMode: String = "system"
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showLogoutAlert = false
    @State private var showBereichAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account").font(.title3).bold()) {
                    HStack(alignment: .center, spacing: 20) {
                        if let data = loginViewModel.profileImageData, let img = UIImage(data: data) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 3))
                                .shadow(radius: 6)
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 72, height: 72)
                                .foregroundColor(.accentColor)
                                .shadow(radius: 6)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loginViewModel.displayName.isEmpty ? loginViewModel.email : loginViewModel.displayName)
                                .font(.title3).bold()
                            if !loginViewModel.jobTitle.isEmpty {
                                Text(loginViewModel.jobTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text(loginViewModel.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(loginViewModel.isLoggedIn ? "Eingeloggt" : "Nicht eingeloggt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color("juliGrey").opacity(0.95))
                    .cornerRadius(18)
                    .shadow(color: Color.accentColor.opacity(0.08), radius: 8, y: 4)
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Text("Abmelden")
                            .foregroundColor(.red)
                            .font(.body.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.07))
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(title: Text("Abmelden?"), message: Text("Möchtest du dich wirklich abmelden?"), primaryButton: .destructive(Text("Abmelden")) { loginViewModel.logout() }, secondaryButton: .cancel())
                    }
                    Button(action: {
                        showBereichAlert = true
                    }) {
                        Label("Bereich wechseln", systemImage: "arrow.left.arrow.right")
                            .foregroundColor(.accentColor)
                            .font(.body.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color("juliYellow").opacity(0.13))
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showBereichAlert) {
                        Alert(title: Text("Bereich wechseln?"), message: Text("Zurück zur Bereichsauswahl?"), primaryButton: .default(Text("Wechseln")) { loginViewModel.ausgewaehlterBereich = .keine }, secondaryButton: .cancel())
                    }
                }
                Section(header: SectionHeader(title: "App")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundColor(Color(.label).opacity(0.5))
                    }
                    Picker("Design", selection: $themeMode) {
                        Text("System").tag("system")
                        Text("Hell").tag("light")
                        Text("Dunkel").tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: themeMode) { mode in
                        switch mode {
                        case "light": UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                        case "dark": UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                        default: UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
                        }
                    }
                    Link(destination: URL(string: "https://github.com/julis-sh/mitgliederinfo-app/releases")!) {
                        Label("Changelog", systemImage: "doc.text.magnifyingglass")
                            .font(.body.bold())
                            .foregroundColor(Color(.label))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color("juliYellow").opacity(0.13))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color("juliGrey").opacity(0.98))
                .cornerRadius(18)
                .shadow(color: Color("juliBlack").opacity(0.06), radius: 8, y: 4)
                Section(header: SectionHeader(title: "Support")) {
                    Link(destination: URL(string: "mailto:luca.kohls@julis-sh.de")!) {
                        Label("Feedback & Kontakt", systemImage: "envelope")
                            .font(.body.bold())
                            .foregroundColor(Color(.label))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color("juliYellow").opacity(0.13))
                            .cornerRadius(10)
                    }
                    Link(destination: URL(string: "https://julis-sh.de/faq/")!) {
                        Label("FAQ", systemImage: "questionmark.circle")
                            .font(.body.bold())
                            .foregroundColor(Color(.label))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color("juliYellow").opacity(0.13))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color("juliGrey").opacity(0.98))
                .cornerRadius(18)
                .shadow(color: Color("juliBlack").opacity(0.06), radius: 8, y: 4)
                Section(header: SectionHeader(title: "Rechtliches")) {
                    NavigationLink(destination: DatenschutzView()) {
                        Text("Datenschutz")
                            .font(.body.bold())
                            .foregroundColor(Color(.label))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color("juliYellow").opacity(0.13))
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: ImpressumView()) {
                        Text("Impressum")
                            .font(.body.bold())
                            .foregroundColor(Color(.label))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color("juliYellow").opacity(0.13))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color("juliGrey").opacity(0.98))
                .cornerRadius(18)
                .shadow(color: Color("juliBlack").opacity(0.06), radius: 8, y: 4)
            }
            .navigationTitle("Einstellungen")
        }
    }
}

struct DatenschutzView: View {
    var body: some View {
        ScrollView {
            Text("""
DATENSCHUTZERKLÄRUNG DER JUNGEN LIBERALEN SCHLESWIG-HOLSTEIN E.V.

Im Folgenden informieren wir Sie über die Erhebung personenbezogener Daten bei Nutzung unserer Webseite www.julis-sh.de der Jungen Liberalen Schleswig-Holstein e. V. und deren Social-Media-Kanäle. Personenbezogene Daten sind alle Daten, die auf Sie persönlich beziehbar sind, z.B. Name, Adresse, E-Mail-Adressen und Seitenaufrufe.

I. Verantwortlicher

Verantwortliche für die Datenverarbeitung gem. Art. 4 Abs. 7 EU-Datenschutz-Grundverordnung (nachfolgend: EU-DSGVO) ist:

Junge Liberale Schleswig-Holstein e. V. (nachfolgend: JuLis SH)
Eichhofstr. 25-27
24116 Kiel

vertreten durch: Finn Flebbe (Landesvorsitzender)
E-Mail: info@julis-sh.de

Der Datenschutzbeauftragte der JuLis SH ist:

Junge Liberale Schleswig-Holstein e. V.
z. Hd. Luca Stephan Kohls, Datenschutzbeauftragter
Eichhofstr. 25-27
24116 Kiel
E-Mail: datenschutz@julis-sh.de

II. Grundsätze unserer Datenerhebung

(1) Wir erheben in der Regel personenbezogenen Daten im Sinne von Art. 4 Nr. 1 EU-DSGVO: "Alle Informationen, die sich auf eine identifizierte oder identifizierbare natürliche Person (im Folgenden "betroffene Person") beziehen; als identifizierbar wird eine natürliche Person angesehen, die direkt oder indirekt, insbesondere mittels Zuordnung zu einer Kennung wie einem Namen, zu einer Kennnummer, zu Standortdaten, zu einer Online-Kennung oder zu einem oder mehreren besonderen Merkmalen, die Ausdruck der physischen, physiologischen, genetischen, psychischen, wirtschaftlichen, kulturellen oder sozialen Identität dieser natürlichen Person sind, identifiziert werden kann."

(2) Sollten wir für die Verarbeitung Deiner Daten externe Dienstleister beauftragen, werden wir diese sorgfältig auswählen und gesondert beauftragten, sodass dieser im Rahmen einer Auftragsverarbeitung an den Weisungen der JuLis SH gebunden sind und regelmäßig kontrolliert wird. Wenn dieser Dienstleister seinen Sitz in einem Staat außerhalb des Europäischen Wirtschaftsraums hat, informieren wir Dich über die Folgen dieses Umstands in der Beschreibung des Angebotes.

(3) Alle nach Nr. 1 erhobenen Daten werden nur so lange gespeichert, wie es für die Zwecke, für die sie verarbeitet werden, erforderlich ist.

III. Weitergabe von Daten

Eine Übermittlung der von den JuLis SH erhobenen Daten an Dritte findet grundsätzlich nicht statt, außer in den folgenden gesetzlichen Ausnahmen:

a. Du hast nach Art. 6 Abs. 1 S. 1 lit. a EU-DSGVO Deine ausdrückliche Einwilligung dazu erteilt,  
b. wenn dies gesetzlich zulässig und nach Art. 6 Abs. 1 S. 1 lit. b EU-DSGVO für die Abwicklung von Vertragsverhältnissen mit Dir erforderlich ist,  
c. es für die Weitergabe eine gesetzliche Verpflichtung nach Art. 6 Abs. 1 S. 1 lit. c EU-DSGVO besteht, und  
d. wenn die Weitergabe nach Art. 6 Abs. 1 S. 1 lit. f EU-DSGVO zur Geltendmachung, Ausübung oder Verteidigung von Rechtsansprüchen erforderlich ist und es kein Grund zur Annahme besteht, dass du ein überwiegendes schutzwürdiges Interesse an einer Nichtweitergabe deiner Daten hast.

IV. Deine Rechte

(1) Du hast gegenüber den JuLis SH folgende Rechte hinsichtlich der Dich betreffenden erhobenen Daten:

a. Recht auf Auskunft nach Art. 15 EU-DSGVO;  
b. Recht auf Berichtigung nach Art. 16 EU-DSGVO;  
c. Recht auf Löschung nach Art. 17 EU-DSGVO, soweit nicht die Verarbeitung zur Ausübung des Rechts auf freie Meinungsäußerung und Information, zur Erfüllung einer rechtlichen Verpflichtung, aus Gründen des öffentlichen Interesses oder zur Geltendmachung, Ausübung oder Verteidigung von Rechtsansprüchen erforderlich ist;  
d. Recht auf Einschränkung der Verarbeitung nach Art. 18 EU-DSGVO, wenn die Richtigkeit der Daten von Dir bestritten wird; wenn die Verarbeitung unrechtmäßig ist, Du jedoch statt Löschen eine Einschränkung verlangst; wenn wir die Daten nicht mehr benötigen, Du dennoch diese zur Geltendmachung, Ausübung oder Verteidigung von Rechtsansprüchen benötigst oder Du gem. Art. 21 EU-DSGVO Widerspruch gegen die Verarbeitung eingelegt hast;  
e. Recht auf Datenübertragbarkeit nach Art. 20 EU-DSGVO;  
f. Recht auf Widerspruch gegen die Verarbeitung gem. Art. 21 EU-DSGVO (siehe hierzu Punkt V dieser Datenschutzerklärung).

(2) Du hast zudem das Recht, Dich nach Art. 77 EU-DSGVO bei der zuständigen Datenschutz-Aufsichtsbehörde über die Verarbeitung Deiner personenbezogenen Daten durch den JuLis SH zu beschweren. Die für die JuLis SH zuständige Datenschutz-Aufsichtsbehörde ist das 

Unabhängiges Landeszentrum für Datenschutz Schleswig-Holstein  
Holstenstraße 98  
24103 Kiel.

V. Widerspruchsrecht

Das Recht auf Widerspruch aus Nr. 4 Abs. 2 dieser Datenschutzerklärung umfasst gem. Art. 21 EU-DSGVO insbesondere die folgenden Fälle:

(1) Eine eventuell erteilte Einwilligung gem. Art. 7 Abs. 3 EU-DSGVO kannst Du jederzeit widerrufen.  
(2) Sollten Deine Daten aufgrund der Vertragserfüllung erhoben und verarbeitet worden sein, ist auch ein Widerruf möglich. Einer möglichen Löschung der Daten stehen eventuell gesetzliche Vorgaben entgegen.  
(3) Sollte sich die Datenverarbeitung auf eine Interessenabwägung stützen, kannst Du Widerspruch gegen die Verarbeitung einlegen. Dies ist der Fall, wenn die Verarbeitung insbesondere nicht zur Erfüllung eines Vertrags mit Dir erforderlich ist, was jedoch jeweils gesondert dargelegt wird. Bei Ausübung eines solchen Widerspruchs bitten wir um Darlegung der Gründe, weshalb die JuLis SH Deine personenbezogenen Daten nicht wie durchgeführt verarbeiten sollten. In diesem Fallen prüfen die JuLis SH die Sachlage und werden entweder die Datenverarbeitung einstellen bzw. anpassen oder Dir die zwingenden schutzwürdigen Gründe der JuLis SH aufzeigen, aufgrund derer die Verarbeitung fortgeführt wird.  
(4) Über Deinen Widerspruch kannst Du die JuLIs SH unter folgenden Kontaktdaten informieren:

Junge Liberale Schleswig-Holstein e. V.  
z. Hd. Luca Stephan Kohls, Datenschutzbeauftragter  
Eichhofstr. 25-27  
24116 Kiel  
E-Mail: datenschutz@julis-sh.de

[... Der Text ist sehr lang. Bitte den vollständigen Text von https://julis-sh.de/datenschutz/ einfügen ...]

Die jeweils aktuelle Datenschutzerklärung kannst Du jederzeit auf dieser Webseite unter https://julis-sh.de/datenschutz/ abrufen und ausdrucken.
""")
            .padding()
        }
        .navigationTitle("Datenschutz")
    }
}

struct ImpressumView: View {
    var body: some View {
        ScrollView {
            Text("""
IMPRESSUM

Angaben gemäß § 5 TMG:

Junge Liberale Schleswig-Holstein e. V.
Eichhofstraße 25-27
24116 Kiel

Vereinsregister: VR 1565
Registergericht: Amtsgericht Lübeck

Vertreten durch den Landesvorsitzenden:
Finn Flebbe
E-Mail: info@julis-sh.de

Inhaltlich Verantwortlicher gemäß § 55 Abs. 2 RStV:
Finn Flebbe
E-Mail: info@julis-sh.de

Technische Verantwortung & Datenschutz:
Luca Stephan Kohls
Landesgeschäftsstelle der Jungen Liberalen Schleswig-Holstein
Eichhofstraße 25-27
24116 Kiel
E-Mail: luca.kohls@julis-sh.de

Haftungshinweis:
Trotz sorgfältiger inhaltlicher Kontrolle übernehmen wir keine Haftung für die Inhalte externer Links. Für den Inhalt der verlinkten Seiten sind ausschließlich deren Betreiber verantwortlich.

Unsere Datenschutzerklärung ist unter https://julis-sh.de/datenschutz/ jederzeit aufrufbar.
""")
            .padding()
        }
        .navigationTitle("Impressum")
    }
}

#Preview {
    SettingsView().environmentObject(LoginViewModel())
} 