import SwiftUI
import SwiftData

struct ManageWordsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Verb.infinitive) private var verbs: [Verb]
    @Query(sort: \Noun.singular) private var nouns: [Noun]

    var body: some View {
        NavigationStack {
            List {
                if !verbs.isEmpty {
                    Section("Verbs (\(verbs.count))") {
                        ForEach(verbs) { verb in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(verb.infinitive).font(.body.weight(.semibold))
                                Text(verb.translation).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            for i in offsets { context.delete(verbs[i]) }
                            try? context.save()
                        }
                    }
                }

                if !nouns.isEmpty {
                    Section("Nouns (\(nouns.count))") {
                        ForEach(nouns) { noun in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(noun.article) \(noun.singular)").font(.body.weight(.semibold))
                                Text(noun.translation).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            for i in offsets { context.delete(nouns[i]) }
                            try? context.save()
                        }
                    }
                }

                if verbs.isEmpty && nouns.isEmpty {
                    ContentUnavailableView("No words yet", systemImage: "tray",
                        description: Text("Add flashcards with the + button."))
                }
            }
            .navigationTitle("My Words")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                #endif
            }
        }
        .frame(minWidth: 400, minHeight: 500)   // macOS sheet sizing
    }
}