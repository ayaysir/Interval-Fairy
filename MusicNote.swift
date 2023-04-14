//
//  MusicNote.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/10.
//

import Foundation

struct MusicNote: Codable, Equatable, Comparable {
    enum Scale7: Int, Codable {
        case C = 0
        case D = 1
        case E = 2
        case F = 3
        case G = 4
        case A = 5
        case B = 6
    }
    
    enum Accidental: Int, Codable {
        case doubleFlat = -2
        case flat = -1
        case natural = 0
        case sharp = 1
        case doubleSharp = 2
        
        func adjust(_ adjustCount: Int) -> Accidental? {
            let adjustedIndex = self.rawValue + adjustCount
            return Accidental(rawValue: adjustedIndex)
        }
    }
    
    var scale7: Scale7 = .C
    var accidental: Accidental = .natural
    var octave: Int = 4
    
    var midiSemitone: Int {
        // C4 = 60
        return (octave + 1) * 12 + scale7.rawValue
    }
    
    static func < (lhs: MusicNote, rhs: MusicNote) -> Bool {
        return lhs.midiSemitone < rhs.midiSemitone
    }
    
    static func fromMIDINoteNumber(_ number: Int8, key: Scale7 = .C) -> MusicNote {
        let randomNum = Int.random(in: 0...6)
        return MusicNote(scale7: Scale7(rawValue: randomNum)!, accidental: .natural, octave: 4)
    }
}
