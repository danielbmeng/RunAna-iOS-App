import PhotosUI
import SwiftUI
import UIKit

enum CreditPack: CaseIterable, Identifiable {
    case five
    case twenty
    case fifty
    case twoHundred

    var id: String {
        switch self {
        case .five: return "five"
        case .twenty: return "twenty"
        case .fifty: return "fifty"
        case .twoHundred: return "twoHundred"
        }
    }

    var credits: Double {
        switch self {
        case .five: return 5
        case .twenty: return 20
        case .fifty: return 50
        case .twoHundred: return 200
        }
    }
}

struct ContentView: View {
    @StateObject private var analyzer = RunAnalyzerService()
    @StateObject private var usageLimiter = DailyUsageLimiter()
    @StateObject private var historyStore = AnalysisHistoryStore()

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []
    @State private var selectedTones: Set<CaptionTone> = [.fresh, .philosophical]
    @State private var theme: AppTheme = .minimal
    @State private var language: AppLanguage = .preferred
    @State private var apiKey = SecureKeyStore.loadSavedOpenAIKey()
    @State private var result: CaptionResult?
    @State private var errorMessage: String?
    @State private var copied = false

    private var localized: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        TabView {
            NavigationStack {
                createView
                    .navigationTitle("RunAna")
            }
            .tabItem {
                Label(localized.text(.analyzeTab), systemImage: "sparkles")
            }

            NavigationStack {
                historyView
                    .navigationTitle(localized.text(.historyTab))
            }
            .tabItem {
                Label(localized.text(.historyTab), systemImage: "clock")
            }

            NavigationStack {
                settingsView
                    .navigationTitle(localized.text(.settingsTab))
            }
            .tabItem {
                Label(localized.text(.settingsTab), systemImage: "gearshape")
            }
        }
        .tint(theme.color)
    }

    private var createView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                headerView
                photoPickerView
                tonePickerView
                generateButton
                resultView
            }
            .padding()
        }
        .background(theme.background.ignoresSafeArea())
        .onChange(of: selectedPhotos) { _, newItems in
            Task {
                await loadPhotos(from: newItems)
            }
        }
        .alert("RunAna", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            RunAnaMarkView(theme: theme, size: 74)
            Text(localized.text(.appSubtitle))
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Text(localized.text(.disclaimer))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var photoPickerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(images.isEmpty ? localized.text(.uploadTitle) : localized.text(.uploadReady))
                .font(.headline)
            Text(images.isEmpty ? localized.text(.uploadSubtitle) : localized.text(.uploadReadySubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(images.enumerated()), id: \.offset) { pair in
                            Image(uiImage: pair.element)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 92, height: 122)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }

            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 3,
                matching: .images
            ) {
                Label(
                    images.isEmpty ? localized.text(.choosePhotos) : localized.text(.changePhotos),
                    systemImage: "photo.on.rectangle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .sectionStyle(theme: theme)
    }

    private var tonePickerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(localized.text(.toneSection))
                    .font(.headline)
                Spacer()
                Text(localized.text(.toneLimit))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            FlowLayout(spacing: 8) {
                ForEach(CaptionTone.allCases) { tone in
                    Button {
                        toggleTone(tone)
                    } label: {
                        Text(localized.toneName(tone))
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(selectedTones.contains(tone) ? .white : theme.color)
                    .background(selectedTones.contains(tone) ? theme.color : theme.softColor)
                    .clipShape(Capsule())
                }
            }
        }
        .sectionStyle(theme: theme)
    }

    private var generateButton: some View {
        Button {
            Task {
                await analyze()
            }
        } label: {
            Label(localized.text(.generateButton), systemImage: "wand.and.stars")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(images.isEmpty || analyzer.isAnalyzing)
        .controlSize(.large)
    }

    @ViewBuilder
    private var resultView: some View {
        if analyzer.isAnalyzing {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
        } else if let result {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(localized.text(.captionNotes))
                        .font(.headline)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = result.displayText
                        copied = true
                    } label: {
                        Label(copied ? localized.text(.copied) : localized.text(.copyAll), systemImage: "doc.on.doc")
                    }
                    .font(.caption)
                }

                captionBlock(title: localized.text(.shortCaption), text: result.shortCaption)
                captionBlock(title: localized.text(.longCaption), text: result.longCaption)
            }
            .sectionStyle(theme: theme)
        } else {
            Text(localized.text(.placeholder))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .sectionStyle(theme: theme)
        }
    }

    private var historyView: some View {
        List {
            if historyStore.items.isEmpty {
                ContentUnavailableView(
                    localized.text(.noCaptions),
                    systemImage: "text.bubble",
                    description: Text(localized.text(.noCaptionsDescription))
                )
            } else {
                ForEach(historyStore.items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(item.text)
                            .font(.body)
                    }
                    .padding(.vertical, 6)
                }
                .onDelete(perform: historyStore.delete)
            }
        }
    }

    private var settingsView: some View {
        Form {
            Section(localized.text(.themeSection)) {
                Picker(localized.text(.themeSection), selection: $theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(localized.themeName(theme)).tag(theme)
                    }
                }
            }

            Section(localized.text(.languageSection)) {
                Picker(localized.text(.languageSection), selection: $language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                SecureField("sk-...", text: $apiKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: apiKey) { _, newValue in
                        SecureKeyStore.saveOpenAIKey(newValue)
                    }
                Text(localized.text(.apiHelp))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text(localized.text(.openAISection))
            }

            Section {
                Text(String(format: "%.1f credits", usageLimiter.credits))
                ForEach(CreditPack.allCases) { pack in
                    Button(localized.creditPackName(pack)) {
                        usageLimiter.add(pack.credits)
                    }
                }
            } header: {
                Text(localized.text(.proTitle))
            } footer: {
                Text(localized.text(.proBody))
            }
        }
    }

    private func captionBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.body)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @MainActor
    private func loadPhotos(from items: [PhotosPickerItem]) async {
        var loadedImages: [UIImage] = []

        for item in items.prefix(3) {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    throw CaptionLoadError.failed
                }
                loadedImages.append(image)
            } catch {
                errorMessage = localized.text(.photoLoadFailed)
            }
        }

        images = loadedImages
        result = nil
        copied = false
    }

    @MainActor
    private func analyze() async {
        let effectiveKey = SecureKeyStore.effectiveOpenAIKey(userKey: apiKey)
        guard !effectiveKey.isEmpty else {
            errorMessage = localized.text(.apiKeyMissing)
            return
        }

        guard usageLimiter.canAnalyze else {
            errorMessage = localized.text(.proBody)
            return
        }

        do {
            let caption = try await analyzer.analyze(
                images: images,
                tones: Array(selectedTones),
                apiKey: effectiveKey,
                languageInstruction: language.analysisInstruction
            )
            result = caption
            copied = false
            usageLimiter.spend(caption.isValidPhotoSet ? 1 : 0.5)
            historyStore.add(title: caption.title, text: caption.displayText)

            if !caption.isValidPhotoSet {
                errorMessage = localized.text(.invalidPhotoCredit)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggleTone(_ tone: CaptionTone) {
        if selectedTones.contains(tone) {
            selectedTones.remove(tone)
        } else if selectedTones.count < 3 {
            selectedTones.insert(tone)
        }
    }
}

private enum CaptionLoadError: Error {
    case failed
}

private struct SectionStyle: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.color.opacity(0.12), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private extension View {
    func sectionStyle(theme: AppTheme) -> some View {
        modifier(SectionStyle(theme: theme))
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 320
        let rows = rows(for: subviews, maxWidth: maxWidth)
        let height = rows.reduce(CGFloat.zero) { partial, row in
            partial + row.height
        } + CGFloat(max(0, rows.count - 1)) * spacing

        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(for: subviews, maxWidth: bounds.width)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var currentItems: [RowItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextWidth = currentItems.isEmpty ? size.width : currentWidth + spacing + size.width

            if nextWidth > maxWidth, !currentItems.isEmpty {
                rows.append(Row(items: currentItems, height: currentHeight))
                currentItems = [RowItem(index: index, size: size)]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(RowItem(index: index, size: size))
                currentWidth = nextWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentItems.isEmpty {
            rows.append(Row(items: currentItems, height: currentHeight))
        }

        return rows
    }

    private struct Row {
        let items: [RowItem]
        let height: CGFloat
    }

    private struct RowItem {
        let index: Int
        let size: CGSize
    }
}

#Preview {
    ContentView()
}
