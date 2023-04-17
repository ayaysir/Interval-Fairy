//
//  IntervalInfoView.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/17.
//

import SwiftUI
import Tonic

struct IntervalInfoView: View {
    @State var title = "Major Thyrd"
    @State var note1: Note
    @State var note2: Note
    @State private var interval: Tonic.Interval?
    
    let musiqwikFont: Font = .custom("Musiqwik", size: 60)
    
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
            HStack(spacing: 50) {
                // 악보 겹치기 (되나?)
                ZStack {
                    /*
                     3도 이상인 경우
                     -> 그냥 겹치면 됨
                     2도인 경우 (예: 도레, 미파...)
                     -> 더 높은 음표의 위치를 뒤로
                        "'==y=!"
                        "'=x==!"
                     완전 1도인 경우
                     -> 한개만
                     */
                    if let interval = interval {
                        if interval.number >= 3 {
                            Text("'=\(note1.musiqwik)=!")
                                .font(musiqwikFont)
                            Text("'=\(note2.musiqwik)=!")
                                .font(musiqwikFont)
                        } else if interval.number == 2 {
                            Text("'=\((note1.noteNumber > note2.noteNumber ? note1 : note2).musiqwik)=!")
                                .font(musiqwikFont)
                            Text("'\((note1.noteNumber < note2.noteNumber ? note1 : note2).musiqwik)==!")
                                .font(musiqwikFont)
                        } 
                    } else {
                        Text("Error")
                    }
                }
                
                Text("'\(note1.musiqwik)\(note2.musiqwik)=!")
                    .font(musiqwikFont)
            }
            
        }.onAppear {
            if let interval = Tonic.Interval.betweenNotes(note1, note2) {
                self.interval = interval
                title = interval.longDescription
            }
        }
    }
}

struct IntervalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        IntervalInfoView(note1: .Eb, note2: .B)
    }
}
