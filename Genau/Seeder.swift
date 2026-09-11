import Foundation
import SwiftData

/// Seeds the catalog with basic DaF A1 vocabulary
struct Seeder {
    
    static func seedCatalogIfNeeded(context: ModelContext) {
        // Check if catalog is already seeded
        let descriptor = FetchDescriptor<CatalogWord>()
        let existing = (try? context.fetch(descriptor)) ?? []
        
        guard existing.isEmpty else {
            print("Catalog already seeded with \(existing.count) words")
            return
        }
        
        print("Seeding catalog with DaF A1 vocabulary...")
        
        // Seed nouns
        for noun in a1Nouns {
            let word = CatalogWord(
                lemma: noun.lemma,
                type: "noun",
                translation: noun.translation,
                frequency: noun.frequency,
                level: "A1",
                article: noun.article,
                gender: noun.gender,
                plural: noun.plural
            )
            context.insert(word)
        }
        
        // Seed verbs
        for verb in a1Verbs {
            let word = CatalogWord(
                lemma: verb.lemma,
                type: "verb",
                translation: verb.translation,
                frequency: verb.frequency,
                level: "A1",
                isSeparable: verb.isSeparable,
                auxiliary: verb.auxiliary,
                partizip2: verb.partizip2,
                praesens: verb.praesens
            )
            context.insert(word)
        }
        
        try? context.save()
        
        let count = (try? context.fetch(descriptor))?.count ?? 0
        print("Catalog seeded with \(count) words")
    }
    
    // MARK: - A1 Nouns (from standard DaF A1 curriculum)
    
    private static let a1Nouns: [(lemma: String, article: String, gender: String, plural: String, translation: String, frequency: Double)] = [
        // Familie & Menschen
        ("Mann", "der", "masculine", "Männer", "man", 95.0),
        ("Frau", "die", "feminine", "Frauen", "woman", 95.0),
        ("Kind", "das", "neuter", "Kinder", "child", 90.0),
        ("Mutter", "die", "feminine", "Mütter", "mother", 85.0),
        ("Vater", "der", "masculine", "Väter", "father", 85.0),
        ("Familie", "die", "feminine", "Familien", "family", 80.0),
        ("Freund", "der", "masculine", "Freunde", "friend (male)", 75.0),
        ("Freundin", "die", "feminine", "Freundinnen", "friend (female)", 75.0),
        
        // Haus & Wohnung
        ("Haus", "das", "neuter", "Häuser", "house", 88.0),
        ("Wohnung", "die", "feminine", "Wohnungen", "apartment", 82.0),
        ("Zimmer", "das", "neuter", "Zimmer", "room", 78.0),
        ("Tisch", "der", "masculine", "Tische", "table", 70.0),
        ("Stuhl", "der", "masculine", "Stühle", "chair", 68.0),
        ("Bett", "das", "neuter", "Betten", "bed", 72.0),
        ("Tür", "die", "feminine", "Türen", "door", 65.0),
        ("Fenster", "das", "neuter", "Fenster", "window", 65.0),
        
        // Essen & Trinken
        ("Brot", "das", "neuter", "Brote", "bread", 75.0),
        ("Wasser", "das", "neuter", "", "water", 85.0),
        ("Kaffee", "der", "masculine", "", "coffee", 80.0),
        ("Tee", "der", "masculine", "", "tea", 75.0),
        ("Milch", "die", "feminine", "", "milk", 70.0),
        ("Apfel", "der", "masculine", "Äpfel", "apple", 68.0),
        
        // Stadt & Verkehr
        ("Stadt", "die", "feminine", "Städte", "city", 85.0),
        ("Auto", "das", "neuter", "Autos", "car", 82.0),
        ("Bus", "der", "masculine", "Busse", "bus", 75.0),
        ("Zug", "der", "masculine", "Züge", "train", 78.0),
        ("Straße", "die", "feminine", "Straßen", "street", 80.0),
        
        // Zeit
        ("Tag", "der", "masculine", "Tage", "day", 92.0),
        ("Jahr", "das", "neuter", "Jahre", "year", 88.0),
        ("Uhr", "die", "feminine", "Uhren", "clock, time", 82.0),
        ("Stunde", "die", "feminine", "Stunden", "hour", 78.0),
        
        // Schule & Arbeit
        ("Schule", "die", "feminine", "Schulen", "school", 85.0),
        ("Lehrer", "der", "masculine", "Lehrer", "teacher (male)", 78.0),
        ("Lehrerin", "die", "feminine", "Lehrerinnen", "teacher (female)", 78.0),
        ("Arbeit", "die", "feminine", "", "work", 88.0),
        ("Buch", "das", "neuter", "Bücher", "book", 80.0),
        
        // Natur & Tiere
        ("Katze", "die", "feminine", "Katzen", "cat", 70.0),
        ("Hund", "der", "masculine", "Hunde", "dog", 72.0),
        
        // Körper
        ("Hand", "die", "feminine", "Hände", "hand", 75.0),
        ("Auge", "das", "neuter", "Augen", "eye", 70.0),
    ]
    
    // MARK: - A1 Verbs (from standard DaF A1 curriculum)
    
    private static let a1Verbs: [(lemma: String, translation: String, isSeparable: Bool, auxiliary: String, partizip2: String, praesens: Praesens?, frequency: Double)] = [
        // Essential verbs
        ("sein", "to be", false, "sein", "gewesen", 
         Praesens(ich: "bin", du: "bist", erSieEs: "ist", wir: "sind", ihr: "seid", sieSie: "sind"), 100.0),
        
        ("haben", "to have", false, "haben", "gehabt",
         Praesens(ich: "habe", du: "hast", erSieEs: "hat", wir: "haben", ihr: "habt", sieSie: "haben"), 98.0),
        
        ("machen", "to do, to make", false, "haben", "gemacht",
         Praesens(ich: "mache", du: "machst", erSieEs: "macht", wir: "machen", ihr: "macht", sieSie: "machen"), 90.0),
        
        ("gehen", "to go", false, "sein", "gegangen",
         Praesens(ich: "gehe", du: "gehst", erSieEs: "geht", wir: "gehen", ihr: "geht", sieSie: "gehen"), 92.0),
        
        ("kommen", "to come", false, "sein", "gekommen",
         Praesens(ich: "komme", du: "kommst", erSieEs: "kommt", wir: "kommen", ihr: "kommt", sieSie: "kommen"), 88.0),
        
        ("sehen", "to see", false, "haben", "gesehen",
         Praesens(ich: "sehe", du: "siehst", erSieEs: "sieht", wir: "sehen", ihr: "seht", sieSie: "sehen"), 85.0),
        
        ("sprechen", "to speak", false, "haben", "gesprochen",
         Praesens(ich: "spreche", du: "sprichst", erSieEs: "spricht", wir: "sprechen", ihr: "sprecht", sieSie: "sprechen"), 82.0),
        
        ("essen", "to eat", false, "haben", "gegessen",
         Praesens(ich: "esse", du: "isst", erSieEs: "isst", wir: "essen", ihr: "esst", sieSie: "essen"), 80.0),
        
        ("trinken", "to drink", false, "haben", "getrunken",
         Praesens(ich: "trinke", du: "trinkst", erSieEs: "trinkt", wir: "trinken", ihr: "trinkt", sieSie: "trinken"), 78.0),
        
        ("schreiben", "to write", false, "haben", "geschrieben",
         Praesens(ich: "schreibe", du: "schreibst", erSieEs: "schreibt", wir: "schreiben", ihr: "schreibt", sieSie: "schreiben"), 75.0),
        
        ("lesen", "to read", false, "haben", "gelesen",
         Praesens(ich: "lese", du: "liest", erSieEs: "liest", wir: "lesen", ihr: "lest", sieSie: "lesen"), 75.0),
        
        ("wohnen", "to live, to reside", false, "haben", "gewohnt",
         Praesens(ich: "wohne", du: "wohnst", erSieEs: "wohnt", wir: "wohnen", ihr: "wohnt", sieSie: "wohnen"), 72.0),
        
        ("heißen", "to be called", false, "haben", "geheißen",
         Praesens(ich: "heiße", du: "heißt", erSieEs: "heißt", wir: "heißen", ihr: "heißt", sieSie: "heißen"), 85.0),
        
        ("arbeiten", "to work", false, "haben", "gearbeitet",
         Praesens(ich: "arbeite", du: "arbeitest", erSieEs: "arbeitet", wir: "arbeiten", ihr: "arbeitet", sieSie: "arbeiten"), 80.0),
        
        ("lernen", "to learn", false, "haben", "gelernt",
         Praesens(ich: "lerne", du: "lernst", erSieEs: "lernt", wir: "lernen", ihr: "lernt", sieSie: "lernen"), 82.0),
        
        ("kaufen", "to buy", false, "haben", "gekauft",
         Praesens(ich: "kaufe", du: "kaufst", erSieEs: "kauft", wir: "kaufen", ihr: "kauft", sieSie: "kaufen"), 70.0),
        
        ("kochen", "to cook", false, "haben", "gekocht",
         Praesens(ich: "koche", du: "kochst", erSieEs: "kocht", wir: "kochen", ihr: "kocht", sieSie: "kochen"), 68.0),
        
        // Separable verb
        ("ankommen", "to arrive", true, "sein", "angekommen",
         Praesens(ich: "komme an", du: "kommst an", erSieEs: "kommt an", wir: "kommen an", ihr: "kommt an", sieSie: "kommen an"), 75.0),
    ]
}
