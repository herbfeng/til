import Foundation
import AppIntents
import SwiftData

struct LogTILIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a TIL"
    
    @Parameter(title: "Content")
    var content: String

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = try ModelContainer(for: TILPost.self)
        let context = ModelContext(container)
        context.insert(TILPost(content: content))
        try context.save()
        return .result(value: "Saved to Herb's TIL")
    }
}

struct TILShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: LogTILIntent(), phrases: ["Log a \(.applicationName)"], shortTitle: "Log TIL", systemImageName: "lightbulb.fill")
    }
}
