import SwiftUI
import SwiftData

struct AddFlashcardView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var search = ""
    @State private var results: [CatalogWord] = []
    @State private var justAdded: String? = nil
    @State private var showingImport = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(results) { word in
                    Button {
                        let added = PracticeManager.addToPractice(word, context: context)
                        justAdded = added ? "Added \(word.lemma)" : "\(word.lemma) already added"
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(word.type == "noun"
                                     ? "\(word.article ?? "") \(word.lemma)"
                                     : word.lemma)
                                    .font(.body.weight(.semibold))
                                Text(word.translation)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(word.type == "verb" ? "V" : "N")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }

                if !search.isEmpty && results.isEmpty {
                    Text("No matches for "\(search)".")
                        .foregroundStyle(.secondary)
                }
            }
            .searchable(text: $search, prompt: "Type a German word, e.g. rauchen")
            .onChange(of: search) { _, newValue in runSearch(newValue) }
            .navigationTitle("Add Flashcard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingImport = true
                    } label: {
                        Label("Import Chapter", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showingImport) {
                ImportChapterView()
            }
            .overlay(alignment: .bottom) {
                if let justAdded {
                    Text(justAdded)
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { self.justAdded = nil }
                            }
                        }
                }
            }
        }
    }

    private func runSearch(_ term: String) {
        let q = term.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { results = []; return }

        var descriptor = FetchDescriptor<CatalogWord>(
            predicate: #Predicate { $0.searchText.contains(q) },
            sortBy: [SortDescriptor(\.frequency, order: .reverse)]
        )
        descriptor.fetchLimit = 50
        results = (try? context.fetch(descriptor)) ?? []
    }
}
