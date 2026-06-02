import SwiftUI

struct RunAnaMarkView: View {
    let theme: AppTheme
    var size: CGFloat = 92

    var body: some View {
        Image("RunAnaLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.18))
            .shadow(color: theme.color.opacity(0.16), radius: size * 0.12, y: size * 0.06)
            .accessibilityLabel("RunAna logo")
    }
}
