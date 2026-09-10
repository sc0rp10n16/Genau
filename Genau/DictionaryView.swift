import SwiftUI
import SwiftData

struct DictionaryView: View {
    @Environment(\.modelContext) private var context

    @State private var search = ""
    @State private var results: [CatalogWord] = []

    var body: some View {
        NavigationStack {
            List {
                if search.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "Search the dictionary",
                            systemImage: "book",
                            description: Text("Type a German or English word to look it up.")
                        )
                    }
                } else {
                    ForEach(results, id: \.persistentModelID) { word in
                        NavigationLink {
                            CatalogDetailView(word: word)
                        } label: {
                            row(for: word)
                        }
                    }

                    // Wiktionary escape hatch for anything not in the catalog.
                    Section {
                        Link(destination: wiktionaryURL(search)) {
                            Label("Look up “\(search)” on Wiktionary", systemImage: "arrow.up.right.square")
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Search German or English")
            .onChange(of: search) { _, newValue in runSearch(newValue) }
            .navigationTitle("Dictionary")
        }
    }

    private func row(for word: CatalogWord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.type == "noun" ? "\(word.article ?? "") \(word.lemma)" : word.lemma)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(colorFor(word))
                Text(word.translation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(word.type == "verb" ? "V" : "N")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(4)
                .background(.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
        }
    }

    private func colorFor(_ word: CatalogWord) -> Color {
        guard word.type == "noun" else { return .primary }
        switch word.article {
        case "der": return .blue
        case "die": return .red
        case "das": return .green
        default:    return .primary
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

    private func wiktionaryURL(_ term: String) -> URL {
        let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? term
        return URL(string: "https://de.wiktionary.org/wiki/\(encoded)")!
    }
}