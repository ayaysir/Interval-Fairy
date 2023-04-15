//
//  StarView.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/15.
//

import SwiftUI
import Tonic

struct StarView: View {
    @StateObject var conductor: InstrumentEXSConductor
    @StateObject var starVM: StarViewModel
    @State var index: Int
    @State var handler: () -> Void
    
    var body: some View {
        ZStack {
            Image("uglystar")
            Text(starVM.noteName[index].noteClass.description)
            if starVM.isTapped[index] {
                SwiftUIGIFPlayerView(gifName: "PoppingStar")
                    .frame(width: 32, height: 32)
            }
        }
        .offset(x: starVM.offsets[index].width, y: starVM.offsets[index].height)
        .frame(width: 32, height: 32)
        .onTapGesture {
            starVM.isTapped[index] = true
            
            conductor.noteOn(pitch: Pitch(starVM.noteName[index].noteNumber), point: .zero)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                conductor.noteOff(pitch: Pitch(starVM.noteName[index].noteNumber))
                starVM.resetValues(playIndex: index)
                handler()
            }
        }
        .isHidden(starVM.hideStar[index])
    }
}
