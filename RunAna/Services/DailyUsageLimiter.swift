import Combine
import Foundation

@MainActor
final class DailyUsageLimiter: ObservableObject {
    @Published private(set) var credits: Double = 3

    init() {
        if !SecureKeyStore.hasSeededInitialCredits {
            SecureKeyStore.saveCredits(3)
            SecureKeyStore.hasSeededInitialCredits = true
        }
        credits = SecureKeyStore.loadCredits() ?? 0
    }

    var canAnalyze: Bool {
        credits >= 1
    }

    func spend(_ amount: Double) {
        credits = max(0, credits - amount)
        SecureKeyStore.saveCredits(credits)
    }

    func add(_ amount: Double) {
        credits += amount
        SecureKeyStore.saveCredits(credits)
    }
}
