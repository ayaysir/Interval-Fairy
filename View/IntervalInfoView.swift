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
    @State var baseNotes: [String] = []
    
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
            if let interval = interval {
                VStack(alignment: .leading) {
                    Text("Why \(title)?").font(.title2)
                    VStack(alignment: .leading) {
                        Text("1. Counting the size between the low and high notes equals \(interval.number). (\(baseNotes.joined(separator: ", ")))")
                        Text("  - The number of an interval is the number of letter names or staff positions (lines and spaces) it encompasses, including the positions of both notes forming the interval. ").font(.footnote)
                        Image("LineAndSpace")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                    }
                    Spacer().frame(height: 20)
                    Text("2. If the size is x and the number of semitones is y, it defaults to a 'perfect fifth.'")
                    
                    // if 낮은 음이 변화한 경우
                    Text("3. Here, the note in the lower position is raised/lowered by 1 step(s), so it becomes a ****.")
                    // if 높은 음이 변화한 경우
                    Text("4. Also, since the note in the higher position is raised by 1 step(s), it becomes a ****.")
                    Spacer().frame(height: 10)
                    Text("Therefore, the final interval will be ***.")
                }
            }
            
        }.onAppear {
            if let interval = Tonic.Interval.betweenNotes(note1, note2) {
                self.interval = interval
                title = interval.longDescription
                let isAscending = note1.noteNumber < note2.noteNumber
                self.baseNotes = baseNoteList(interval: interval, startLetter: isAscending ? note1.letter : note2.letter)
                if !isAscending {
                    self.baseNotes.reverse()
                }
                
            }
        }
        .padding(sides: [.left, .right], value: 20)
    }
}

struct IntervalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        IntervalInfoView(note1: .Eb, note2: .B)
    }
}
