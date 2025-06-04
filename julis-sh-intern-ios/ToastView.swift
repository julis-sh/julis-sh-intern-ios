import SwiftUI

struct ToastView: View {
    let message: String
    var body: some View {
        if !message.isEmpty {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.85))
                .cornerRadius(16)
                .shadow(radius: 8)
        }
    }
}

#Preview {
    ToastView(message: "Benutzer gespeichert.")
} 