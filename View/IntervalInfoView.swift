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
    // @State private var defaultInterval: Tonic.Interval?
    @State private var isAccidentalBoth = false
    @State private var defaultIntervalDescription = ""
    @State private var defaultHalfStepCount = 0
    
    @Environment(\.dismiss) var dismiss
    @StateObject var conductor: InstrumentEXSConductor
    
    var lowerNote: Note {
        return note1.noteNumber < note2.noteNumber ? note1 : note2
    }
    var higherNote: Note {
        return note1.noteNumber > note2.noteNumber ? note1 : note2
    }
    
    let musiqwikFont: Font = .custom("Musiqwik", size: 60)
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.largeTitle)
            HStack(spacing: 50) {
                VStack {
                    // 악보 겹치기
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
                                Text("'&=\(note1.musiqwik)=!")
                                    .font(musiqwikFont)
                                Text("'&=\(note2.musiqwik)=!")
                                    .font(musiqwikFont)
                            } else if interval.number == 2 {
                                Text("'&=\((note1.noteNumber > note2.noteNumber ? note1 : note2).musiqwik)=!")
                                    .font(musiqwikFont)
                                Text("'&\((note1.noteNumber < note2.noteNumber ? note1 : note2).musiqwik)==!")
                                    .font(musiqwikFont)
                            }
                        } else {
                            Text("Error")
                        }
                    }
                    Button {
                        conductor.playTwoNotes()
                    } label: {
                        Image(systemName: "play.fill")
                    }

                }
                VStack {
                    Text("'&\(note1.musiqwik)\(note2.musiqwik)=!")
                        .font(musiqwikFont)
                    Button {
                        conductor.playTwoNotesHorizontally()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
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
                    Text("2. If the size is \(interval.number) and the number of half step is \(defaultHalfStepCount), it defaults to a '\(defaultIntervalDescription).'")
                    
                    // if 양쪽 모두 높이 변화가 없는 경우
                    if !isAccidentalBoth {
                        Text("3. And on both notes, accidental is not attached. That is, there is no change in size from the basic interval.")
                    } else {
                        // if 낮은 음이 변화한 경우
                        if lowerNote.accidental != .natural {
                            Text("3. Here, the note in the lower position is \(lowerNote.accidental == .flat ? "lowered" : "raised") by 1 half step, so it becomes a the size of the interval is \(lowerNote.accidental == .flat ? "expanded" : "shrinked").")
                            
                            if higherNote.accidental != .natural {
                                Text("4. Also, since the note in the higher position is \(higherNote.accidental == .flat ? "lowered" : "raised") by 1 step, so it becomes a the size of the interval is \(higherNote.accidental == .flat ? "shrinked" : "expanded").")
                            }
                        } else if higherNote.accidental != .natural {
                            Text("3. Here, the note in the higher position is \(higherNote.accidental == .flat ? "lowered" : "raised") by 1 half step, so it becomes a the size of the interval is \(higherNote.accidental == .flat ? "shrinked" : "expanded").")
                        }
                    }
                    Spacer().frame(height: 10)
                    Text("Therefore, the final interval will be \(title).")
                }
                Spacer().frame(height: 100)
                Button {
                    dismiss()
                } label: {
                    Text("OK, Got it!")
                }
            }
            
        }.onAppear {
            print(lowerNote, higherNote)
            if let interval = Tonic.Interval.betweenNotes(note1, note2) {
                self.interval = interval
                title = interval.longDescription
                let isAscending = note1.noteNumber < note2.noteNumber
                self.baseNotes = baseNoteList(interval: interval, startLetter: isAscending ? note1.letter : note2.letter)
                if !isAscending {
                    self.baseNotes.reverse()
                }
                
                // default interval
                let defaultNote1 = Note(note1.letter, accidental: .natural, octave: note1.octave)
                let defaultNote2 = Note(note2.letter, accidental: .natural, octave: note2.octave)
                if let defaultInterval = Tonic.Interval.betweenNotes(defaultNote1, defaultNote2) {
                    defaultIntervalDescription = defaultInterval.longDescription
                    isAccidentalBoth = interval.description != defaultInterval.description
                    
                    // default half step count
                    switch defaultInterval {
                    case .P1, .M2, .M3, .m6:
                        defaultHalfStepCount = 0
                    case .m2, .m3, .P4, .P5, .M6, .M7:
                        defaultHalfStepCount = 1
                    case .m7:
                        defaultHalfStepCount = 2
                    default:
                        break
                    }
                }
                
            }
        }
        .padding(sides: [.left, .right], value: 20)
    }
}

struct IntervalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        IntervalInfoView(note1: .Eb, note2: .B, conductor: InstrumentEXSConductor())
    }
}
