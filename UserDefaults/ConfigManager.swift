//
//  ConfigManager.swift.swift
//  
//
//  Created by 윤범태 on 2023/04/19.
//

import Foundation

extension String {
    static let cfgFairyName = "CONFIG_FAIRYNAME"
}

class ConfigManager {
    static var shared = ConfigManager()
    
    var fairyName: String? {
        get {
            UserDefaults.standard.string(forKey: .cfgFairyName)
        } set {
            UserDefaults.standard.set(newValue, forKey: .cfgFairyName)
        }
    }
}
