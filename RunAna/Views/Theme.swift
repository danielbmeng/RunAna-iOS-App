import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case minimal
    case sage
    case rose
    case ink
    case sun

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .minimal:
            return Color(red: 0.08, green: 0.10, blue: 0.13)
        case .sage:
            return Color(red: 0.26, green: 0.48, blue: 0.39)
        case .rose:
            return Color(red: 0.72, green: 0.38, blue: 0.46)
        case .ink:
            return Color(red: 0.18, green: 0.22, blue: 0.31)
        case .sun:
            return Color(red: 0.84, green: 0.52, blue: 0.14)
        }
    }

    var softColor: Color {
        switch self {
        case .minimal:
            return Color(red: 0.94, green: 0.94, blue: 0.93)
        case .sage:
            return Color(red: 0.88, green: 0.94, blue: 0.90)
        case .rose:
            return Color(red: 0.99, green: 0.90, blue: 0.92)
        case .ink:
            return Color(red: 0.90, green: 0.92, blue: 0.96)
        case .sun:
            return Color(red: 1.00, green: 0.95, blue: 0.84)
        }
    }

    var background: Color {
        switch self {
        case .minimal:
            return Color(red: 0.985, green: 0.982, blue: 0.976)
        case .sage:
            return Color(red: 0.95, green: 0.98, blue: 0.95)
        case .rose:
            return Color(red: 1.00, green: 0.96, blue: 0.97)
        case .ink:
            return Color(red: 0.95, green: 0.96, blue: 0.98)
        case .sun:
            return Color(red: 1.00, green: 0.98, blue: 0.93)
        }
    }
}
