//
//  Interval+.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/18.
//

import Tonic

extension Tonic.Interval {
    var number: Int {
        let degreeText = self.longDescription.split(separator: " ")[1]
        switch degreeText {
        case "First", "Unison": return 1
        case "Second": return 2
        case "Third": return 3
        case "Fourth": return 4
        case "Fifth": return 5
        case "Sixth": return 6
        case "Seventh": return 7
        case "Octave": return 8
        default: return -99999
        }
    }
}
