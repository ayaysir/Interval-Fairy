import SwiftUI
import AudioKit
import SoundpipeAudioKit
import AudioKitUI
import Keyboard

class InstrumentEXSConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = MIDISampler(name: "Instrument 1")
    var displayKey: Key = .C
    @Published var intervalDescription: String = ""
    
    private var note1: Note?
    private var note2: Note?

    func noteOn(pitch: Pitch, point _: CGPoint) {
        // print(Date(), MusicNote.fromMIDINoteNumber(pitch.midiNoteNumber))
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
        if note1 == nil {
            note1 = Note(pitch: Pitch(pitch.midiNoteNumber), key: displayKey)
        } else if note2 == nil {
            note2 = Note(pitch: Pitch(pitch.midiNoteNumber), key: displayKey)
        }
    }

    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
        
        if let note1 = note1, let note2 = note2 {
            if let interval = Tonic.Interval.betweenNotes(note1, note2) {
                print(interval)
                intervalDescription = interval.longDescription
            }
            self.note1 = nil
            self.note2 = nil
        }
    }

    init() {
        engine.output = instrument

        // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
        do {
            if let fileURL = Bundle.main.url(forResource: "Box Harp - Picked", withExtension: "exs") {
                try instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }
}

struct ContentView: View {
    @StateObject var conductor = InstrumentEXSConductor()
    
    let keyList: [Key] = [.C, .Db, .D, .Eb, .E, .F, .Gb, .G, .Ab, .A, .Bb, .B]
    @State var currentKeyIndex = 0
    @State private var isDisplayFlat = false
    
    @State private var showFallStar = false
    
    @StateObject var starVM = StarViewModel(maxCapacity: 3)
    
    @State var star0_appeared = false
    @State var star1_appeared = false
    @State var star2_appeared = false
    @State var star0_elapsedSeconds = 0
    @State var star1_elapsedSeconds = 0
    @State var star2_elapsedSeconds = 0
    
    private var keyTextIndex: Int {
        if currentKeyIndex == keyList.count - 1 {
            return currentKeyIndex + (isDisplayFlat ? -1 : 0)
        }
        
        return currentKeyIndex + (isDisplayFlat ? 1 : 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)
            HStack {
                Button {
                    
                } label: {
                    Label("View Status", systemImage: "chart.bar.fill")
                }
                Spacer()
                Button {
                    
                } label: {
                    Label("Help", systemImage: "questionmark.circle.fill")
                }
                Button {
                    
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }.padding([.leading, .trailing], 10)
            
            Spacer()
            
            ZStack(alignment: .top) {
                // 밑으로 갈수록 z-index 높음
                
                Image("sample3")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width)
                // Stars
                StarView(conductor: conductor, starVM: starVM, index: 0) {
                    star0_elapsedSeconds = 0
                }
                StarView(conductor: conductor, starVM: starVM, index: 1) {
                    star1_elapsedSeconds = 0
                }
                StarView(conductor: conductor, starVM: starVM, index: 2) {
                    star2_elapsedSeconds = 0
                }
            }
            
            VStack(spacing: 0) {
                ZStack {
                    Color.orange
                    HStack {
                        Spacer()
                        Text(conductor.intervalDescription)
                        Button("Toggle Sharp/Flat") {
                            isDisplayFlat.toggle()
                            conductor.displayKey = keyList[keyTextIndex]
                        }
                        Button("-") {
                            guard currentKeyIndex > 0 else {
                                return
                            }
                            currentKeyIndex -= 1
                            
                        }
                        Button("C") {
                            currentKeyIndex = 0
                        }
                        Button("+") {
                            guard currentKeyIndex < keyList.count - 1 else {
                                return
                            }
                            currentKeyIndex += 1
                        }
                    }
                }
                Keyboard(
                    layout: .piano(
                        pitchRange: Pitch(60 + keyList[currentKeyIndex].number) ... Pitch(72 + keyList[currentKeyIndex].number)),
                    noteOn: conductor.noteOn,
                    noteOff: conductor.noteOff) { pitch, isActivated in
                    KeyboardKey(pitch: pitch,
                                isActivated: isActivated,
                                text: pitch.note(in: keyList[keyTextIndex]).description,
                                pressedColor: Color(PitchColor.newtonian[Int(pitch.pitchClass)]),
                                alignment: .bottom)
                }
                    .shadow(radius: 5)
                    .frame(height: 240)
            }
        }
        .onAppear {
            conductor.start()
            print(Bundle.main)
            
            /*
             랜덤으로 별사탕 뿌리기
             간격:
              - 한 화면 맥스 3개
              - 별사탕 뿌리는 것은 20~30초 랜덤
              - 첫 별사탕은 무조건 5초 후, 그 이후 30초 ~40초 랜덤
              - 이미 별사탕이 화면에 있는 경우(timer가 invalidate되지 않은 경우) 뿌리지 않음
              - invalidate 확인된 경우 10~20초 후에 새로운 별사탕
             */
            starVM.invalidatedHandler = { index in
                switch index {
                case 0:
                    star0_elapsedSeconds = 0
                case 1:
                    star1_elapsedSeconds = 0
                case 2:
                    star2_elapsedSeconds = 0
                default:
                    break
                }
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                star0_elapsedSeconds += 1
                star1_elapsedSeconds += 1
                star2_elapsedSeconds += 1
                
                if !star0_appeared && star0_elapsedSeconds == 3 {
                    starVM.startAnimation(playIndex: 0)
                    star0_elapsedSeconds = 0
                    star0_appeared = true
                }
                
                if !star1_appeared && star1_elapsedSeconds == 15 {
                    starVM.startAnimation(playIndex: 1)
                    star1_elapsedSeconds = 0
                    star1_appeared = true
                }
                
                if !star2_appeared && star2_elapsedSeconds == 30 {
                    starVM.startAnimation(playIndex: 2)
                    star2_elapsedSeconds = 0
                    star2_appeared = true
                }
                
                if star0_appeared && starVM.hideStar[0] && star0_elapsedSeconds == 12 {
                    starVM.startAnimation(playIndex: 0)
                    star0_elapsedSeconds = 0
                }
                
                if star1_appeared && starVM.hideStar[1] && star1_elapsedSeconds == 11 {
                    starVM.startAnimation(playIndex: 1)
                    star1_elapsedSeconds = 0
                }
                
                if star2_appeared && starVM.hideStar[2] && star2_elapsedSeconds == 13 {
                    starVM.startAnimation(playIndex: 2)
                    star2_elapsedSeconds = 0
                }
            }
        }.onDisappear {
            conductor.stop()
        }
    }
}
