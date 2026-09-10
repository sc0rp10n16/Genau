import SwiftUI
import SwiftData

struct CatalogDetailView: View {
    @Environment(\.modelContext) private var context
    let word: CatalogWord

    @State private var addedMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Headword
                Text(word.type == "noun" ? "\(word.article ?? "") \(word.lemma)" : word.lemma)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(colorFor(word))

                Button {
                    Speaker.shared.speak(word.type == "noun" ? "\(word.article ?? "") \(word.lemma)" : word.lemma)
                } label: {
                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                }
                .buttonStyle(.plain)

                Text(word.translation)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Divider()

                // Noun details
                if word.type == "noun" {
                    if let plural = word.plural, !plural.isEmpty {
                        Text("Plural: die \(plural)").font(.headline)
                    }
                }

                // Verb details — conjugation table
                if word.type == "verb", let p = word.praesens {
                    VStack(alignment: .leading, spacing: 8) {
                        conjRow("ich", p.ich)
                        conjRow("du", p.du)
                        conjRow("er/sie/es", p.erSieEs)
                        conjRow("wir", p.wir)
                        conjRow("ihr", p.ihr)
                        conjRow("sie/Sie", p.sieSie)
                    }
                    if let pp = word.partizip2, !pp.isEmpty {
                        Text("Perfekt: \(word.auxiliary ?? "haben") \(pp)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Add to practice
                Button {
                    let added = PracticeManager.addToPractice(word, context: context)
                    addedMessage = added ? "Added to flashcards" : "Already in flashcards"
                } label: {
                    Label("Add to my flashcards", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)

                if let addedMessage {
                    Text(addedMessage).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(32)
        }
        .navigationTitle(word.lemma)
    }

    private func conjRow(_ pronoun: String, _ form: String) -> some View {
        HStack {
            Text(pronoun).foregroundStyle(.secondary).frame(width: 90, alignment: .leading)
            Text(form).font(.body.weight(.semibold))
            Spacer()
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
}