import SwiftUI

struct ContentView: View {
    private func test_getAboveIntervalNoteFrom(_ text: String, _ note: MusicNote?) {
        guard let note = note else {
            return
        }
        
        let component = text.components(separatedBy: ", ")
        
        print(component, note.scale7, note.accidental, note.octave)
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }.onAppear {
            // ******** TEST (재래식) ********
            
            // countOfHalfStep:  be
            // 4, 8, 11, 15, 18, 22...
            // 1, 2,  3,  4,  5,  6...
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 3))
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 4))
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 7))
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 8))
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 11))
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 15))
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 18))
            print(IntervalHelper.shared.countOfHalfStep(scale7: .C, intervalNumber: 22))
            
            //
            let major_3 = Interval(quality: .major, number: 3)
            let major_6 = Interval(quality: .major, number: 6)
            let major_7 = Interval(quality: .major, number: 7)

            let minor_3 = Interval(quality: .minor, number: 3)
            let minor_6 = Interval(quality: .minor, number: 6)
            let minor_7 = Interval(quality: .minor, number: 7)

            let perfect_4 = Interval(quality: .perfect, number: 4)
            let perfect_5 = Interval(quality: .perfect, number: 5)

            let aug_1 = Interval(quality: .augmented, number: 1)
            let aug_2 = Interval(quality: .augmented, number: 2)

            let dim_5 = Interval(quality: .diminished, number: 5)

            let calc = IntervalHelper.shared.aboveIntervalNoteFrom
            
            // 2) 장음정
            // 2-1) 장 3도 이하이고, 두 음 사이에 반음이 없다면, prefix는 그대로 따라간다.
            // 예) C# -> E#, Gb -> Bb, G -> B
            test_getAboveIntervalNoteFrom("E, sharp", calc(MusicNote(scale7: .C, accidental: .sharp), major_3))
            test_getAboveIntervalNoteFrom("B, flat", calc(MusicNote(scale7: .G, accidental: .flat), major_3))
            test_getAboveIntervalNoteFrom("B, nat", calc(MusicNote(scale7: .G, accidental: .natural), major_3))
            
            // 2-2) 장 3도 이하이고, 두 음 사이에 반음이 한 개 있다면 (3-4 또는 7-8), 원래 음에서 반음이 높아진다(=prefix가 1단계 높아진다).
            // 예) E -> G는 E -> G#, Eb -> Gb는 Eb -> G(=)
            test_getAboveIntervalNoteFrom("G, sharp", calc(MusicNote(scale7: .E, accidental: .natural), major_3))
            test_getAboveIntervalNoteFrom("G, nat", calc(MusicNote(scale7: .E, accidental: .flat), major_3))
            
            // 2-3) 장 6 ~ 7도이고, 두 음 사이에 반음이 한 개 있다면 prefix는 그대로 따라간다.
            // 예) C -> A, Db -> Bb, G# -> E#
            test_getAboveIntervalNoteFrom("A, nat", calc(MusicNote(scale7: .C, accidental: .natural), major_6))
            test_getAboveIntervalNoteFrom("B, flat", calc(MusicNote(scale7: .D, accidental: .flat), major_6))
            test_getAboveIntervalNoteFrom("E, sharp, +1", calc(MusicNote(scale7: .G, accidental: .sharp), major_6))
            
            // 2-4) 장 6 ~ 7도이고, 두 음 사이에 반음이 두 개 있다면, 원래 음에서 반음이 높아진다(=prefix가 1단계 높아진다).
            // 예) E -> C# (EF, BC), A -> F# (BC, EF), Bb -> G (BC, EF)
            test_getAboveIntervalNoteFrom("D, sharp, +1", calc(MusicNote(scale7: .E, accidental: .natural), major_7))
            test_getAboveIntervalNoteFrom("F, sharp, +1", calc(MusicNote(scale7: .A, accidental: .natural), major_6))
            test_getAboveIntervalNoteFrom("G, nat, +1", calc(MusicNote(scale7: .B, accidental: .flat), major_6))
            
            // 3) 단음정
            // 장음정을 기준으로 먼저 계산한 뒤, 반음 내린다(=prefix는 1단계 낮아진다).
            // 예1) C -> Eb (단 3도, from E), Eb -> Gb (단 3도, from G), Gb -> Bbb (from Bb), F# -> A (단 3도, from A#)
            // 예2) E -> C (from C#), Db -> Bbb (from Bb), Bb -> Ab (from A)
            test_getAboveIntervalNoteFrom("E, flat", calc(MusicNote(scale7: .C, accidental: .natural), minor_3))
            test_getAboveIntervalNoteFrom("G, flat", calc(MusicNote(scale7: .E, accidental: .flat), minor_3))
            test_getAboveIntervalNoteFrom("B, DoubleFlat", calc(MusicNote(scale7: .G, accidental: .flat), minor_3))
            test_getAboveIntervalNoteFrom("A, nat", calc(MusicNote(scale7: .F, accidental: .sharp), minor_3))
            
            test_getAboveIntervalNoteFrom("C, nat, +1", calc(MusicNote(scale7: .E, accidental: .natural), minor_6))
            test_getAboveIntervalNoteFrom("B, DoubleFlat", calc(MusicNote(scale7: .D, accidental: .flat), minor_6))
            test_getAboveIntervalNoteFrom("A, flat, +1", calc(MusicNote(scale7: .B, accidental: .flat), minor_7))
            
            // 4) 완전음정
            // 4-1) 완전음정 사이에 반음이 한 개 있다면, prefix는 그대로 따라간다.
            // 예) C -> F (EF), Eb -> Ab (EF), Bb -> Eb (BC), E -> B
            test_getAboveIntervalNoteFrom("F, nat", calc(MusicNote(scale7: .C, accidental: .natural), perfect_4))
            test_getAboveIntervalNoteFrom("A, flat", calc(MusicNote(scale7: .E, accidental: .flat), perfect_4))
            test_getAboveIntervalNoteFrom("E, flat,+ 1", calc(MusicNote(scale7: .B, accidental: .flat), perfect_4))
            test_getAboveIntervalNoteFrom("B, nat,", calc(MusicNote(scale7: .C, accidental: .natural), perfect_5))

            // 반음 2개?
            // (BC EF)
            test_getAboveIntervalNoteFrom("F, nat, +1", calc(MusicNote(scale7: .B, accidental: .flat), perfect_5))
            test_getAboveIntervalNoteFrom("E, flat, +1", calc(MusicNote(scale7: .A, accidental: .flat), perfect_5))
            
            // 4-2) 완전음정 사이에 반음이 하나도 없다면, 원래 음에서 반음이 낮아진다(=prefix는 1단계 낮아진다).
            // 참고) 이 케이스는 F밖에 존재할 수밖에 없다.
            // 예) F -> Bb, F# -> B, Fb -> Fbb
            test_getAboveIntervalNoteFrom("B, flat", calc(MusicNote(scale7: .F, accidental: .natural), perfect_4))
            test_getAboveIntervalNoteFrom("B, nat", calc(MusicNote(scale7: .F, accidental: .sharp), perfect_4))
            test_getAboveIntervalNoteFrom("B, DoubleFlat", calc(MusicNote(scale7: .F, accidental: .flat), perfect_4))
            
            // 5) 증음정
            // 장음정 또는 완전음정을 기준으로 먼저 계산한 뒤, 반음씩 올리면 된다(=prefix가 1단계 높아진다).
            // 예) C -> C# (증 1도, from C), E -> F## (증 2도, from F#)
            test_getAboveIntervalNoteFrom("C, sharp", calc(MusicNote(scale7: .C, accidental: .natural), aug_1))
            test_getAboveIntervalNoteFrom("F, DoubleSharp", calc(MusicNote(scale7: .E, accidental: .natural), aug_2))
            test_getAboveIntervalNoteFrom("D, nat", calc(MusicNote(scale7: .D, accidental: .flat), aug_1))
            
            // 6) 감음정
            // 감 5도만 있음 (겹증, 겹감, 감 4도(=장 3도) 제외)
            // 완전 5도에서 반음 내린다(=prefix는 1단계 낮아진다).
            // 예) Eb -> Bbb (from Bb), F# -> C (from C#)
            test_getAboveIntervalNoteFrom("B, DoubleFlat", calc(MusicNote(scale7: .E, accidental: .flat), dim_5))
            test_getAboveIntervalNoteFrom("C, nat, +1", calc(MusicNote(scale7: .F, accidental: .sharp), dim_5))
        }
    }
}
