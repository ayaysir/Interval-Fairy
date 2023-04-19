//
//  TamagotchiMovingViewModel.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/17.
//

import SwiftUI

private let step = 20
private let jump = 20

class TamagotchiMovingViewModel: ObservableObject {
    @Published var offset: CGSize = .zero
    
    private var normal: [CGSize] = [
        // 왼쪽으로 4칸 이동
        CGSize(width: -(1 * step), height: 0),
        CGSize(width: -(2 * step), height: 0),
        CGSize(width: -(3 * step), height: 0),
        CGSize(width: -(4 * step), height: 0),
        // 오른쪽으로 4칸 이동
        CGSize(width: -(3 * step), height: -jump),
        CGSize(width: -(2 * step), height: -jump),
        CGSize(width: -(1 * step), height: -jump),
        CGSize(width: -(0 * step), height: -jump),
        // 오른쪽으로 4칸 이동
        CGSize(width: 1 * step, height: -jump),
        CGSize(width: 2 * step, height: -jump),
        CGSize(width: 3 * step, height: -jump),
        CGSize(width: 4 * step, height: -jump),
        // 왼쪽으로 4칸 이동
        CGSize(width: 3 * step, height: 0),
        CGSize(width: 2 * step, height: 0),
        CGSize(width: 1 * step, height: 0),
        CGSize(width: 0 * step, height: 0),
    ]
    private var moveIndex = 0
    
    func moveNormal() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [unowned self] _ in
            offset = normal[moveIndex % normal.count]
            moveIndex += 1
            
        }
    }
}
