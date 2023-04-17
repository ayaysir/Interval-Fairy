//
//  Key+.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/14.
//

import Keyboard

public extension Key {
    func baseNote(_ index: Int) -> UInt8 {
        return [0, 2, 4, 5, 7, 9, 11][index]
    }

    var number: Int8 {
        let baseIndex = self.root.letter.rawValue
        let accidental = self.root.accidental.rawValue
        return Int8(baseNote(baseIndex)) + accidental
    }
}
