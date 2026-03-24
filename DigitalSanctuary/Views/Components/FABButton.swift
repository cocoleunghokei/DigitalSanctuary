import SwiftUI

struct FABButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(LinearGradient.dsPrimaryGradient)
                .clipShape(Circle())
                .shadow(color: Color.dsPrimary.opacity(0.35), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
