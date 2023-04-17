//
//  TamagotchiMovingViewModel.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/17.
//

import SwiftUI

class TamagotchiMovingViewModel: ObservableObject {
    @Published var offset: CGSize = .zero
    
    private var normal: [CGSize] = [
        // 왼쪽으로 4칸 이동
        CGSize(width: -10, height: 0),
        CGSize(width: -20, height: 0),
        CGSize(width: -30, height: 0),
        CGSize(width: -40, height: 0),
        // 오른쪽으로 4칸 이동
        CGSize(width: -30, height: -10),
        CGSize(width: -20, height: -10),
        CGSize(width: -10, height: -10),
        CGSize(width: -0, height: -10),
        // 오른쪽으로 4칸 이동
        CGSize(width: 10, height: -10),
        CGSize(width: 20, height: -10),
        CGSize(width: 30, height: -10),
        CGSize(width: 40, height: -10),
        // 왼쪽으로 4칸 이동
        CGSize(width: 30, height: 0),
        CGSize(width: 20, height: 0),
        CGSize(width: 10, height: 0),
        CGSize(width: 0, height: 0),
    ]
    private var moveIndex = 0
    
    func moveNormal() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [unowned self] _ in
            offset = normal[moveIndex % normal.count]
            moveIndex += 1
            
        }
    }
}
