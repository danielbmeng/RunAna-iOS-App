import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case chinese

    var id: String { rawValue }

    static var preferred: AppLanguage {
        Locale.preferredLanguages.first?.hasPrefix("zh") == true ? .chinese : .english
    }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }

    var analysisInstruction: String {
        switch self {
        case .english: return "Write all app-facing output in natural English."
        case .chinese: return "用自然、有朋友圈气质的简体中文输出。"
        }
    }
}

struct LocalizedText {
    let language: AppLanguage

    func themeName(_ theme: AppTheme) -> String {
        switch theme {
        case .minimal: return text(.minimalTheme)
        case .sage: return text(.sageTheme)
        case .rose: return text(.roseTheme)
        case .ink: return text(.inkTheme)
        case .sun: return text(.sunTheme)
        }
    }

    func toneName(_ tone: CaptionTone) -> String {
        switch language {
        case .english: return tone.englishName
        case .chinese: return tone.chineseName
        }
    }

    func creditPackName(_ pack: CreditPack) -> String {
        switch pack {
        case .five: return text(.fiveCreditPack)
        case .twenty: return text(.twentyCreditPack)
        case .fifty: return text(.fiftyCreditPack)
        case .twoHundred: return text(.twoHundredCreditPack)
        }
    }

    func text(_ key: Key) -> String {
        switch language {
        case .english: return key.english
        case .chinese: return key.chinese
        }
    }

    enum Key {
        case analyzeTab
        case historyTab
        case settingsTab
        case appSubtitle
        case uploadTitle
        case uploadReady
        case uploadSubtitle
        case uploadReadySubtitle
        case choosePhotos
        case changePhotos
        case toneSection
        case toneLimit
        case generateButton
        case captionNotes
        case shortCaption
        case longCaption
        case minimalTheme
        case sageTheme
        case roseTheme
        case inkTheme
        case sunTheme
        case placeholder
        case apiKeyMissing
        case photoLoadFailed
        case noCaptions
        case noCaptionsDescription
        case themeSection
        case languageSection
        case openAISection
        case apiHelp
        case invalidPhotoCredit
        case disclaimer
        case fiveCreditPack
        case twentyCreditPack
        case fiftyCreditPack
        case twoHundredCreditPack
        case proTitle
        case proBody
        case later
        case copied
        case copyAll

        var english: String {
            switch self {
            case .analyzeTab: return "Create"
            case .historyTab: return "History"
            case .settingsTab: return "Settings"
            case .appSubtitle: return "Melancholy captions with a little philosophy"
            case .uploadTitle: return "Upload your best photos"
            case .uploadReady: return "Photos ready"
            case .uploadSubtitle: return "Please upload up to 3 of your best photos. We will read the mood and write for Moments."
            case .uploadReadySubtitle: return "Add, remove, or replace photos before generating."
            case .choosePhotos: return "Choose photos"
            case .changePhotos: return "Change photos"
            case .toneSection: return "Tone"
            case .toneLimit: return "Pick up to 3"
            case .generateButton: return "Generate captions"
            case .captionNotes: return "Caption Drafts"
            case .shortCaption: return "Short"
            case .longCaption: return "Long"
            case .minimalTheme: return "Minimal"
            case .sageTheme: return "Sage"
            case .roseTheme: return "Rose"
            case .inkTheme: return "Ink"
            case .sunTheme: return "Sun"
            case .placeholder: return "Your two captions will appear here: one short and one longer, in the phone language by default."
            case .apiKeyMissing: return "Add your OpenAI API key in Settings first."
            case .photoLoadFailed: return "Could not load the photos."
            case .noCaptions: return "No captions yet"
            case .noCaptionsDescription: return "Recent caption drafts will appear here."
            case .themeSection: return "Theme"
            case .languageSection: return "Language"
            case .openAISection: return "OpenAI API"
            case .apiHelp: return "For testing, enter a key on this device. For release, use your backend so the key is not exposed."
            case .invalidPhotoCredit: return "The photos were unreadable or unsuitable. 0.5 credit was used. Try clearer photos."
            case .disclaimer: return "AI captions are generated from uploaded photos and selected tone tags. Please review before posting."
            case .fiveCreditPack: return "$1.99 - 5 credits"
            case .twentyCreditPack: return "$5.99 - 20 credits"
            case .fiftyCreditPack: return "$9.99 - 50 credits"
            case .twoHundredCreditPack: return "$19.99 - 200 credits"
            case .proTitle: return "Buy credits"
            case .proBody: return "You get 3 free credits on this device. A successful generation uses 1 credit; unreadable photos use 0.5 credit."
            case .later: return "Later"
            case .copied: return "Copied"
            case .copyAll: return "Copy all"
            }
        }

        var chinese: String {
            switch self {
            case .analyzeTab: return "生成"
            case .historyTab: return "历史"
            case .settingsTab: return "设置"
            case .appSubtitle: return "带一点哲学的朋友圈文案"
            case .uploadTitle: return "上传你最好的照片"
            case .uploadReady: return "照片已就绪"
            case .uploadSubtitle: return "请上传最多三张最好的照片，让我们来帮你分析。"
            case .uploadReadySubtitle: return "生成前还可以添加、删除或更换照片。"
            case .choosePhotos: return "选择照片"
            case .changePhotos: return "更换照片"
            case .toneSection: return "格调"
            case .toneLimit: return "最多选 3 个"
            case .generateButton: return "生成文案"
            case .captionNotes: return "文案草稿"
            case .shortCaption: return "短文案"
            case .longCaption: return "长文案"
            case .minimalTheme: return "白色极简"
            case .sageTheme: return "鼠尾草绿"
            case .roseTheme: return "雾粉"
            case .inkTheme: return "墨色"
            case .sunTheme: return "暖阳"
            case .placeholder: return "上传照片后，这里会生成两段朋友圈文案：一短一长，默认跟随手机语言。"
            case .apiKeyMissing: return "请先在设置里填写 OpenAI API key。"
            case .photoLoadFailed: return "照片读取失败。"
            case .noCaptions: return "还没有文案"
            case .noCaptionsDescription: return "最近生成的文案会保存在这里。"
            case .themeSection: return "主题"
            case .languageSection: return "语言"
            case .openAISection: return "OpenAI API"
            case .apiHelp: return "测试版可在本机输入 key。正式发布时应改成后端代理，避免 key 暴露。"
            case .invalidPhotoCredit: return "照片无法清晰分析或不适合生成，已消耗 0.5 credit。请换更清晰的照片。"
            case .disclaimer: return "AI 文案基于上传照片和所选格调生成，发布前请自行确认语气和内容。"
            case .fiveCreditPack: return "$1.99 - 5 credits"
            case .twentyCreditPack: return "$5.99 - 20 credits"
            case .fiftyCreditPack: return "$9.99 - 50 credits"
            case .twoHundredCreditPack: return "$19.99 - 200 credits"
            case .proTitle: return "购买 credits"
            case .proBody: return "同一设备赠送 3 credits。成功生成消耗 1 credit；无法读取或不适合的照片消耗 0.5 credit。"
            case .later: return "稍后"
            case .copied: return "已复制"
            case .copyAll: return "复制全部"
            }
        }
    }
}
