import SwiftUI
import SwiftData

struct GenderDrillView: View {
    @Environment(\.modelContext) private var context
    @Query private var nouns: [Noun]

    @State private var deck: [Noun] = []
    @State private var index = 0
    @State private var selected: String? = nil   // the article the user tapped
    @State private var score = 0
    @State private var answered = 0

    private let articles = ["der", "die", "das"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                if deck.isEmpty {
                    ContentUnavailableView("No nouns yet", systemImage: "tray")
                } else if index >= deck.count {
                    finishedView
                } else {
                    let noun = deck[index]

                    Text("\(score) / \(answered)")
                        .font(.headline).monospacedDigit()
                        .foregroundStyle(.secondary)

                    Spacer()

                    // The prompt: blank article + noun + meaning
                    VStack(spacing: 8) {
                        Text("___ \(noun.singular)")
                            .font(.system(size: 40, weight: .bold))
                        Text(noun.translation)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Three article buttons
                    HStack(spacing: 16) {
                        ForEach(articles, id: \.self) { article in
                            articleButton(article, correct: noun.article)
                        }
                    }

                    // Feedback line
                    if let selected {
                        if selected == noun.article {
                            Text("Genau! 🎉")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.green)
                        } else {
                            Text("Nope — it's \(noun.article) \(noun.singular)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.red)
                        }

                        Button("Next") { advance() }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 8)
                    }

                    Spacer()
                }
            }
            .padding()
            .navigationTitle("der / die / das")
            .onAppear(perform: startIfNeeded)
        }
    }

    // MARK: - Article button with color coding + answer state
    private func articleButton(_ article: String, correct: String) -> some View {
        Button {
            guard selected == nil else { return }   // lock after first tap
            answer(article, correct: correct)
        } label: {
            Text(article)
                .font(.title.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(buttonColor(article, correct: correct))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(selected != nil)
    }

    private func buttonColor(_ article: String, correct: String) -> Color {
        // Before answering: base gender colors.
        guard let selected else {
            return baseColor(article)
        }
        // After answering: correct one green, the wrong pick red, others dimmed.
        if article == correct { return .green }
        if article == selected { return .red }
        return baseColor(article).opacity(0.3)
    }

    private func baseColor(_ article: String) -> Color {
        switch article {
        case "der": return .blue
        case "die": return .red
        case "das": return .green
        default:    return .gray
        }
    }

    // MARK: - Logic
    private func startIfNeeded() {
        guard deck.isEmpty, !nouns.isEmpty else { return }
        deck = nouns.shuffled()
        index = 0; score = 0; answered = 0; selected = nil
    }

    private func answer(_ article: String, correct: String) {
        selected = article
        answered += 1
        let isRight = article == correct

        if isRight { score += 1 }

        // Speak the correct full form so you hear it.
        let noun = deck[index]
        Speaker.shared.speak("\(correct) \(noun.singular)")

        // Track accuracy on the existing ReviewState.
        if let rs = noun.reviewState {
            rs.timesSeen += 1
            if isRight { rs.timesCorrect += 1 }
        } else {
            let rs = ReviewState()
            rs.timesSeen = 1
            rs.timesCorrect = isRight ? 1 : 0
            noun.reviewState = rs
        }
        try? context.save()
    }

    private func advance() {
        selected = nil
        index += 1
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Text("Done!").font(.largeTitle.bold())
            Text("\(score) / \(deck.count) correct")
                .font(.title2).foregroundStyle(.secondary)
            Button("Again") { deck = nouns.shuffled(); index = 0; score = 0; answered = 0; selected = nil }
                .buttonStyle(.borderedProminent)
        }
    }
}