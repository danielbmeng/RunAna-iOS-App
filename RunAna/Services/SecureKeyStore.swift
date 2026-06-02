import Foundation
import Security

enum SecureKeyStore {
    private static let service = "com.dannyzhang.MelancholyPhilosopher"
    private static let openAIAccount = "openai_api_key"
    private static let creditsAccount = "caption_credit_balance"
    private static let hasSeededCreditsAccount = "caption_has_seeded_initial_credits"
    static func loadSavedOpenAIKey() -> String {
        readString(account: openAIAccount) ?? ""
    }

    static func effectiveOpenAIKey(userKey: String = "") -> String {
        let trimmedUserKey = userKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedUserKey.isEmpty {
            return trimmedUserKey
        }

        let savedKey = loadSavedOpenAIKey().trimmingCharacters(in: .whitespacesAndNewlines)
        if !savedKey.isEmpty {
            return savedKey
        }

        return ""
    }

    static func saveOpenAIKey(_ key: String) {
        writeString(key, account: openAIAccount)
    }

    static func loadCredits() -> Double? {
        guard let value = readString(account: creditsAccount) else { return nil }
        return Double(value)
    }

    static func saveCredits(_ credits: Double) {
        writeString(String(credits), account: creditsAccount)
    }

    static var hasSeededInitialCredits: Bool {
        get { readString(account: hasSeededCreditsAccount) == "true" }
        set { writeString(newValue ? "true" : "false", account: hasSeededCreditsAccount) }
    }

    private static func readString(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    private static func writeString(_ string: String, account: String) {
        let data = Data(string.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }
}
