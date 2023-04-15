//
//  Note+.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/15.
//

import Tonic

public extension Note {
    static func randomNote() -> Note {
        let notes: [Note] = [
            .A, .Ab, .As,
            .B, .Bb, .Bs,
            .C, .Cb, .Cs,
            .D, .Db, .Ds,
            .E, .Eb,
            .F, .Fb, .Fs,
            .G, .Gb,
        ]
        
        let index = Int.random(in: 0..<notes.count)
        return notes[index]
    }
}
