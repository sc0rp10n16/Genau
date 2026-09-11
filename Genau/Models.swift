import Foundation
import SwiftData

// MARK: - Practice Models

@Model
final class Verb {
    var infinitive: String
    var translation: String
    var isSeparable: Bool
    var auxiliary: String
    var partizip2: String
    var praesens: Praesens?
    var reviewState: ReviewState?
    
    init(
        infinitive: String,
        translation: String,
        isSeparable: Bool = false,
        auxiliary: String = "haben",
        partizip2: String = "",
        praesens: Praesens? = nil
    ) {
        self.infinitive = infinitive
        self.translation = translation
        self.isSeparable = isSeparable
        self.auxiliary = auxiliary
        self.partizip2 = partizip2
        self.praesens = praesens
    }
}

@Model
final class Noun {
    var singular: String
    var plural: String
    var article: String
    var gender: String
    var translation: String
    var reviewState: ReviewState?
    
    init(
        singular: String,
        plural: String = "",
        article: String = "",
        gender: String = "",
        translation: String
    ) {
        self.singular = singular
        self.plural = plural
        self.article = article
        self.gender = gender
        self.translation = translation
    }
}

@Model
final class ReviewState {
    var timesSeen: Int = 0
    var timesCorrect: Int = 0
    var lastReviewed: Date?
    
    init() {}
}

// MARK: - Supporting Types

struct Praesens: Codable {
    var ich: String
    var du: String
    var erSieEs: String
    var wir: String
    var ihr: String
    var sieSie: String
    
    init(ich: String, du: String, erSieEs: String, wir: String, ihr: String, sieSie: String) {
        self.ich = ich
        self.du = du
        self.erSieEs = erSieEs
        self.wir = wir
        self.ihr = ihr
        self.sieSie = sieSie
    }
}

// Legacy Item model from template
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
