//
//  Interval.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/10.
//

import Foundation

struct Interval: Codable {
    /// Quality란 장, 단 , 감 등을 뜻함
    enum Quality: Codable {
        case diminished, minor, major, perfect, augmented
    }
    
    /// Quality란 장, 단 , 감 등을 뜻함
    var quality: Quality
    /// 장 x도, 단 x도 등에서 x
    var number: Int
}
