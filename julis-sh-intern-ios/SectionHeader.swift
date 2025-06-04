import SwiftUI

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color("juliYellow"))
                .frame(width: 6, height: 24)
                .cornerRadius(3)
            Text(title.uppercased())
                .font(.headline)
                .foregroundColor(Color("juliBlack"))
            Spacer()
        }
        .padding(.vertical, 4)
    }
} 