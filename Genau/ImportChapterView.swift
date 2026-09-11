import SwiftUI
import SwiftData

struct ImportChapterView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var pastedText = ""
    @State private var importStatus: ImportStatus = .idle
    @State private var importedCount = 0
    @State private var skippedCount = 0
    @State private var notFoundWords: [String] = []
    
    enum ImportStatus {
        case idle, importing, success, error(String)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $pastedText)
                        .frame(minHeight: 200)
                        .font(.body)
                        .overlay(alignment: .topLeading) {
                            if pastedText.isEmpty {
                                Text("Paste DaF A1 chapter word list here...\n\nExample:\nder Tisch\ndie Katze\nsprechen")
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                            }
                        }
                } header: {
                    Text("Chapter Word List")
                } footer: {
                    Text("Paste German words (one per line). The app will look them up in the catalog and add them to your practice set.")
                }
                
                switch importStatus {
                case .idle:
                    EmptyView()
                case .importing:
                    Section {
                        ProgressView("Importing...")
                    }
                case .success:
                    Section {
                        Label("\(importedCount) words added to practice", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        if skippedCount > 0 {
                            Label("\(skippedCount) words already in practice", systemImage: "info.circle")
                                .foregroundStyle(.blue)
                        }
                        if !notFoundWords.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("\(notFoundWords.count) words not found in catalog:", systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(.orange)
                                ForEach(notFoundWords, id: \.self) { word in
                                    Text("• \(word)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                case .error(let message):
                    Section {
                        Label(message, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Import Chapter Vocab")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        Task {
                            await performImport()
                        }
                    }
                    .disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func performImport() async {
        importStatus = .importing
        
        // Parse the pasted text into individual words
        let lines = pastedText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var imported = 0
        var skipped = 0
        var notFound: [String] = []
        
        for line in lines {
            // Try to look up the word in the catalog
            if let catalogWord = await lookupInCatalog(line) {
                let added = PracticeManager.addToPractice(catalogWord, context: context)
                if added {
                    imported += 1
                } else {
                    skipped += 1
                }
            } else {
                notFound.append(line)
            }
        }
        
        importedCount = imported
        skippedCount = skipped
        notFoundWords = notFound
        importStatus = .success
    }
    
    private func lookupInCatalog(_ searchTerm: String) async -> CatalogWord? {
        // Clean up the search term (remove articles if present)
        let cleaned = searchTerm
            .replacingOccurrences(of: "^(der|die|das)\\s+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
        
        // Search in the catalog
        let descriptor = FetchDescriptor<CatalogWord>(
            predicate: #Predicate { word in
                word.lemma.lowercased() == cleaned
            }
        )
        
        let results = try? context.fetch(descriptor)
        return results?.first
    }
}

#Preview {
    ImportChapterView()
        .modelContainer(for: [CatalogWord.self, Verb.self, Noun.self], inMemory: true)
}
