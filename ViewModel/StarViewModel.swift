//
//  StarViewModel.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/15.
//

import Foundation
import Tonic

class StarViewModel: ObservableObject {
    @Published var offsets: [CGSize]
    private var widths: [CGFloat]
    private var heights: [CGFloat]
    private var timers: [Timer?]

    @Published var isTapped: [Bool]
    @Published var hideStar: [Bool]
    
    @Published var noteName: [Note]
    
    var invalidatedHandler: ((_ index: Int) -> Void)?
    
    init(maxCapacity: Int) {
        let range = 0..<maxCapacity
        self.offsets = range.map { _ in
            CGSize(width: 0, height: 0)
        }
        self.widths = range.map { _ in 0 }
        self.heights = range.map { _ in 0 }
        self.isTapped = range.map { _ in false }
        self.hideStar = range.map { _ in true }
        self.noteName = range.map { _ in Note.randomNote() }
        self.timers = range.map { _ in nil }
    }
    
    func resetValues(playIndex: Int) {
        self.offsets[playIndex] = CGSize(width: 0, height: 0)
        self.widths[playIndex] = 0
        self.heights[playIndex] = 20
        self.isTapped[playIndex] = false
        self.hideStar[playIndex] = true
        self.noteName[playIndex] = Note.randomNote()
        if let timer = self.timers[playIndex] {
            timer.invalidate()
            invalidatedHandler?(playIndex)
        }
    }
    
    func startAnimation(playIndex: Int) {
        hideStar[playIndex] = false
        timers[playIndex] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.widths[playIndex] += CGFloat.random(in: -64...64)
            self.heights[playIndex] += 10
            self.offsets[playIndex] = CGSize(width: self.widths[playIndex], height: self.heights[playIndex])
            
            if self.heights[playIndex] > 512 {
                print("Star No. \(playIndex) is invalidated.")
                self.resetValues(playIndex: playIndex)
            }
        }
    }
}
