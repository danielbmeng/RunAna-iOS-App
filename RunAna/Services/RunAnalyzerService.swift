import Combine
import Foundation
import UIKit

@MainActor
final class RunAnalyzerService: ObservableObject {
    @Published var isAnalyzing = false

    func analyze(images: [UIImage], tones: [CaptionTone], apiKey: String, languageInstruction: String) async throws -> CaptionResult {
        let imagePayloads = images.prefix(3).compactMap { image -> [String: String]? in
            guard let imageData = image.normalizedJPEG(maxDimension: 1280, compression: 0.78) else {
                return nil
            }
            return [
                "type": "input_image",
                "detail": "auto",
                "image_url": "data:image/jpeg;base64,\(imageData.base64EncodedString())"
            ]
        }

        guard imagePayloads.count == images.prefix(3).count else {
            throw CaptionError.imageEncodingFailed
        }

        isAnalyzing = true
        defer { isAnalyzing = false }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let selectedToneText = tones.isEmpty
            ? "natural, poetic, lightly philosophical"
            : tones.map { "\($0.chineseName) / \($0.englishName): \($0.promptHint)" }.joined(separator: "; ")

        let prompt = """
        You are Melancholy Philosopher, a tasteful mobile app that looks at up to three uploaded photos and writes captions for WeChat Moments / social posts.

        Language: \(languageInstruction)
        Selected tone tags: \(selectedToneText)

        Requirements:
        - Analyze visible content, atmosphere, colors, people, place, season, light, and emotional subtext across the photos.
        - Write exactly two captions: one short caption and one longer caption.
        - Make both captions philosophical but postable, concrete to the images, and not generic.
        - Keep the short caption punchy: Chinese 15-35 characters or English 8-18 words.
        - Keep the long caption reflective: Chinese 80-150 characters or English 45-85 words.
        - Avoid hashtags, emojis, quotation marks, markdown, cliché motivational slogans, and mentioning AI.
        - If the photos are unreadable, blank, or unsafe to describe, mark invalid and briefly ask for clearer photos.
        - Do not identify private people, age, race, health status, or sensitive attributes. Describe only visible, non-sensitive details.

        Output format:
        Status: valid or invalid
        Title: a short title for history
        Short: ...
        Long: ...
        """

        var content: [[String: String]] = [
            [
                "type": "input_text",
                "text": prompt
            ]
        ]
        content.append(contentsOf: imagePayloads)

        let body: [String: Any] = [
            "model": "gpt-4.1-mini",
            "input": [
                [
                    "role": "user",
                    "content": content
                ]
            ],
            "max_output_tokens": 520
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CaptionError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let message = OpenAIResponseParser.errorMessage(from: data) ?? "OpenAI request failed with status \(httpResponse.statusCode)."
            throw CaptionError.api(message)
        }

        guard let text = OpenAIResponseParser.outputText(from: data), !text.isEmpty else {
            throw CaptionError.emptyResponse
        }

        return CaptionResult(rawText: text)
    }
}

struct CaptionResult {
    let title: String
    let shortCaption: String
    let longCaption: String
    let isValidPhotoSet: Bool

    var displayText: String {
        "短文案 / Short\n\(shortCaption)\n\n长文案 / Long\n\(longCaption)"
    }

    init(rawText: String) {
        let lines = rawText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)

        let statusLine = lines.first { $0.lowercased().hasPrefix("status:") }
        let statusValue = statusLine?
            .dropFirst("status:".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        isValidPhotoSet = statusValue != "invalid"

        title = Self.value(for: "title:", in: lines) ?? "Caption Draft"
        shortCaption = Self.value(for: "short:", in: lines) ?? ""
        longCaption = Self.value(for: "long:", in: lines) ?? lines
            .filter {
                !$0.lowercased().hasPrefix("status:")
                && !$0.lowercased().hasPrefix("title:")
                && !$0.lowercased().hasPrefix("short:")
            }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func value(for prefix: String, in lines: [String]) -> String? {
        guard let line = lines.first(where: { $0.lowercased().hasPrefix(prefix) }) else {
            return nil
        }
        let parsed = line
            .dropFirst(prefix.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return parsed.isEmpty ? nil : parsed
    }
}

enum CaptionTone: String, CaseIterable, Identifiable {
    case fresh
    case literary
    case philosophical
    case melancholic
    case proud
    case oldMoney
    case energetic
    case cinematic
    case gentle

    var id: String { rawValue }

    var chineseName: String {
        switch self {
        case .fresh: return "小清新"
        case .literary: return "文艺范"
        case .philosophical: return "哲学范"
        case .melancholic: return "忧郁型"
        case .proud: return "小骄傲"
        case .oldMoney: return "老钱从容感"
        case .energetic: return "活力"
        case .cinematic: return "电影感"
        case .gentle: return "温柔松弛"
        }
    }

    var englishName: String {
        switch self {
        case .fresh: return "Fresh"
        case .literary: return "Literary"
        case .philosophical: return "Philosophical"
        case .melancholic: return "Melancholic"
        case .proud: return "Quiet pride"
        case .oldMoney: return "Old-money calm"
        case .energetic: return "Energetic"
        case .cinematic: return "Cinematic"
        case .gentle: return "Gentle ease"
        }
    }

    var promptHint: String {
        switch self {
        case .fresh: return "clean, bright, airy, simple"
        case .literary: return "bookish, refined, image-rich"
        case .philosophical: return "reflective, existential, wise without being heavy"
        case .melancholic: return "soft sadness, restraint, beautiful distance"
        case .proud: return "self-assured, slightly playful, not arrogant"
        case .oldMoney: return "calm confidence, understated elegance"
        case .energetic: return "sunny, alive, forward-moving"
        case .cinematic: return "visual, dramatic light, scene-like"
        case .gentle: return "warm, relaxed, emotionally soft"
        }
    }
}

private enum CaptionError: LocalizedError {
    case imageEncodingFailed
    case invalidResponse
    case emptyResponse
    case api(String)

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "图片压缩失败 / Could not prepare the photos."
        case .invalidResponse:
            return "OpenAI 返回异常 / Invalid OpenAI response."
        case .emptyResponse:
            return "没有读到生成结果 / Empty caption response."
        case .api(let message):
            return message
        }
    }
}

private enum OpenAIResponseParser {
    static func outputText(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return collectOutputText(from: object)
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func errorMessage(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let error = object["error"] as? [String: Any],
            let message = error["message"] as? String
        else {
            return nil
        }
        return message
    }

    private static func collectOutputText(from value: Any) -> [String] {
        if let dict = value as? [String: Any] {
            if dict["type"] as? String == "output_text", let text = dict["text"] as? String {
                return [text]
            }

            return dict.values.flatMap { collectOutputText(from: $0) }
        }

        if let array = value as? [Any] {
            return array.flatMap { collectOutputText(from: $0) }
        }

        return []
    }
}

private extension UIImage {
    func normalizedJPEG(maxDimension: CGFloat, compression: CGFloat) -> Data? {
        let scale = min(1, maxDimension / max(size.width, size.height))
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let rendered = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return rendered.jpegData(compressionQuality: compression)
    }
}
