//
//  BaseNoteList.swift
//  
//
//  Created by 윤범태 on 2023/04/18.
//

import Foundation
import Tonic

func baseNoteList(interval: Tonic.Interval, startLetter: Letter) -> [String] {
    guard interval.number != 1 else {
        return []
    }
    
    let allCases = ["C", "D", "E", "F", "G", "A", "B"]
    let allCasesReverse = allCases.reversed()
    let number = interval.number
    
    return (startLetter.rawValue..<(startLetter.rawValue + number)).map { index in
        return allCases[index % 7]
    }
}
