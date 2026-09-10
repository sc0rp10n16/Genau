import Foundation
import SwiftData

@Model
final class CatalogWord {
    // Common
    var lemma: String            // "Jahr" / "sprechen" — the headword, searchable
    var type: String             // "noun" / "verb"
    var translation: String      // "age, year"
    var frequency: Double
    var level: String

    // Noun-only (empty/nil for verbs)
    var article: String?         // "der"/"die"/"das"
    var gender: String?          // "masculine"/"feminine"/"neuter"
    var plural: String?

    // Verb-only (nil for nouns)
    var isSeparable: Bool
    var auxiliary: String?       // "haben"/"sein"
    var partizip2: String?
    var praesens: Praesens?      // reuse your existing Codable struct

    // Search helper: lowercased lemma + translation, so one predicate covers both languages
    var searchText: String

    init(
        lemma: String,
        type: String,
        translation: String,
        frequency: Double = 0,
        level: String = "A1",
        article: String? = nil,
        gender: String? = nil,
        plural: String? = nil,
        isSeparable: Bool = false,
        auxiliary: String? = nil,
        partizip2: String? = nil,
        praesens: Praesens? = nil
    ) {
        self.lemma = lemma
        self.type = type
        self.translation = translation
        self.frequency = frequency
        self.level = level
        self.article = article
        self.gender = gender
        self.plural = plural
        self.isSeparable = isSeparable
        self.auxiliary = auxiliary
        self.partizip2 = partizip2
        self.praesens = praesens
        self.searchText = "\(lemma) \(translation)".lowercased()
    }
}