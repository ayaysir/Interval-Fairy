//
//  TamagotchiViewModel.swift
//  
//
//  Created by 윤범태 on 2023/04/19.
//

import SwiftUI

class TamagotchiViewModel: ObservableObject {
    @Published var currentImage: Image = Image("year_1")
    @Published var currentWidth: CGFloat = 200
    
    init() {
        setImage()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.setImage()
        }
    }
    
    private func setImage() {
        switch StatusManager.shared.displayAge {
        case 0:
            self.currentImage = Image("year_1")
            self.currentWidth = 150
        case 1:
            self.currentImage = Image("year_2")
            self.currentWidth = 300
        default:
            self.currentImage = Image("Fairy")
            self.currentWidth = 300
        }
    }
}
