import Foundation
import AVFoundation

class Speaker {
    static let shared = Speaker()
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {}
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
