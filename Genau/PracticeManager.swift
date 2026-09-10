import Foundation
import SwiftData

enum PracticeManager {

    @discardableResult
    static func addToPractice(_ word: CatalogWord, context: ModelContext) -> Bool {
        if word.type == "verb" {
            let name = word.lemma
            let existing = (try? context.fetch(
                FetchDescriptor<Verb>(predicate: #Predicate { $0.infinitive == name })
            )) ?? []
            guard existing.isEmpty else { return false }

            let verb = Verb(
                infinitive: word.lemma,
                translation: word.translation,
                isSeparable: word.isSeparable,
                auxiliary: word.auxiliary ?? "haben",
                partizip2: word.partizip2 ?? "",
                praesens: word.praesens
            )
            verb.reviewState = ReviewState()
            context.insert(verb)

        } else {
            let name = word.lemma
            let existing = (try? context.fetch(
                FetchDescriptor<Noun>(predicate: #Predicate { $0.singular == name })
            )) ?? []
            guard existing.isEmpty else { return false }

            let noun = Noun(
                singular: word.lemma,
                plural: word.plural ?? "",
                article: word.article ?? "",
                gender: word.gender ?? "",
                translation: word.translation
            )
            noun.reviewState = ReviewState()
            context.insert(noun)
        }

        try? context.save()
        return true
    }
}