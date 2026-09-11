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
            
            // Only add if we have required verb data from catalog
            guard let auxiliary = word.auxiliary, !auxiliary.isEmpty,
                  let partizip2 = word.partizip2, !partizip2.isEmpty else {
                return false
            }

            let verb = Verb(
                infinitive: word.lemma,
                translation: word.translation,
                isSeparable: word.isSeparable,
                auxiliary: auxiliary,
                partizip2: partizip2,
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
            
            // Only add if we have required noun data from catalog
            guard let article = word.article, !article.isEmpty else {
                return false
            }

            let noun = Noun(
                singular: word.lemma,
                plural: word.plural ?? "",
                article: article,
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