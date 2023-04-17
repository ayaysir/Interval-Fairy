//
//  NoteToMusiqwik.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/18.
//

import Tonic

func noteToMusiqwik(_ note: Note) -> String {
    /*
     let noteIndex: Int = tradKeys.firstIndex(of: pair.noteStr)!
     let notePart = String(UnicodeScalar(114 + noteIndex)!)
     
     var accidentalStartIndex: Int!
     if pair.prefix == "" && !forceNatural {
         return "=\(notePart)"
     } else if pair.prefix == "" && forceNatural {
         accidentalStartIndex = 242
     } else if pair.prefix == "^" {
         accidentalStartIndex = 210
     } else {
         accidentalStartIndex = 226
     }
     
     let accidentalPart = String(UnicodeScalar(accidentalStartIndex + noteIndex)!)
     return accidentalPart + notePart

     */
    let letter = note.letter
    let octave = note.octave
    
    var accidentalText: String {
        switch note.accidental {
        case .sharp:
            return String(UnicodeScalar(210 + letter.rawValue)!)
        case .flat:
            return String(UnicodeScalar(226 + letter.rawValue)!)
        default:
            return "="
        }
    }
    let noteIndexStart = octave == 5 ? 121 : 114
    let noteIndex = noteIndexStart + letter.rawValue
    
    return accidentalText + String(UnicodeScalar(noteIndex)!)
}
