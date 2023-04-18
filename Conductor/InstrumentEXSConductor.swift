//
//  InstrumentEXSConductor.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/17.
//

import SwiftUI
import AudioKit
import Tonic

class InstrumentEXSConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = MIDISampler(name: "Instrument 1")
    var displayKey: Key = .C
    @Published var intervalDescription: String = ""
    @Published var notesDescription: String = "" {
        didSet {
            showAndHideDescription()
        }
    }
    @Published var isIntervalCalculated: Bool = false
    @Published var showDescription: Bool = false
    private var descriptionTimer: Timer?
    
    private(set) var note1: Note?
    private(set) var note2: Note?
    
    func playTwoNotes() {
        if let note1 = note1, let note2 = note2 {
            instrument.stop()
            instrument.play(noteNumber: MIDINoteNumber(note1.pitch.midiNoteNumber), velocity: 90, channel: 1)
            instrument.play(noteNumber: MIDINoteNumber(note2.pitch.midiNoteNumber), velocity: 90, channel: 1)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [unowned self] _ in
                instrument.stop(noteNumber: MIDINoteNumber(note1.pitch.midiNoteNumber), channel: 1)
                instrument.stop(noteNumber: MIDINoteNumber(note2.pitch.midiNoteNumber), channel: 1)
            }
        }
    }
    
    func playTwoNotesHorizontally() {
        if let note1 = note1, let note2 = note2 {
            instrument.stop()
            instrument.play(noteNumber: MIDINoteNumber(note1.pitch.midiNoteNumber), velocity: 90, channel: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) { [unowned self] in
                instrument.stop(noteNumber: MIDINoteNumber(note1.pitch.midiNoteNumber), channel: 1)
                instrument.play(noteNumber: MIDINoteNumber(note2.pitch.midiNoteNumber), velocity: 90, channel: 1)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1200)) { [unowned self] in
                instrument.stop(noteNumber: MIDINoteNumber(note2.pitch.midiNoteNumber), channel: 1)
            }
        }
    }

    func noteOn(pitch: Pitch, point _: CGPoint) {
        isIntervalCalculated = false
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
        
        if note1 == nil || (note1 != nil && note2 != nil) {
            note1 = Note(pitch: Pitch(pitch.midiNoteNumber), key: displayKey)
            note2 = nil
            notesDescription = note1!.description
        } else if note1 != nil && note2 == nil {
            note2 = Note(pitch: Pitch(pitch.midiNoteNumber), key: displayKey)
            notesDescription = "\(note1!.description) and \(note2!.description)"
        }
    }

    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
        
        if let note1 = note1, let note2 = note2 {
            let descBefore = notesDescription
            
            notesDescription = descBefore + " = \n..."
            if let interval = Tonic.Interval.betweenNotes(note1, note2) {
                // 음정 판정 부분
                // Status 조정
                // if emergency { ... } else { adjust status }
                intervalDescription = interval.longDescription
                let quality = interval.longDescription.split(separator: " ")[0]
                
                notesDescription = descBefore + " = \n\(intervalDescription)"
                isIntervalCalculated = true
                
                // TODO: - Status 증가 여부를 표시 (화면 구석에 애니메이팅된 텍스트로)
                StatusManager.shared.discipline += 100
                StatusManager.shared.satiety += 100
                
                switch quality {
                case "Perfect":
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.hygiene += 5000
                    StatusManager.shared.health += 100
                    StatusManager.shared.perfectness += 1000
                case "Major":
                    StatusManager.shared.happy += Int.random(in: 1000...2000)
                    StatusManager.shared.health += 100
                case "Minor":
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.health -= 100
                case "Augmented":
                    StatusManager.shared.age += 40
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.hygiene += 5000
                    StatusManager.shared.health -= 100
                    StatusManager.shared.augDim += Int.random(in: 500...1000)
                case "Diminished":
                    StatusManager.shared.age -= 40
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.health -= 100
                    StatusManager.shared.augDim -= Int.random(in: 500...1000)
                default:
                    break
                }
                
                // StatusManager.shared.printAllStatus()
            } else {
                notesDescription = descBefore + " = \n? (Too difficult to me.)"
            }
            // self.note1 = nil
            // self.note2 = nil
        }
    }

    init() {
        engine.output = instrument

        // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
        do {
            if let fileURL = Bundle.main.url(forResource: "Box Harp - Picked", withExtension: "exs") {
                try instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }
    
    private func showAndHideDescription() {
        showDescription = true
        descriptionTimer?.invalidate()
        descriptionTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { _ in
            self.showDescription = false
        })
    }
}
