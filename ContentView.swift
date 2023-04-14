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
            if let fileURL = Bundle.main.url(forResource: "sawPiano1", withExtension: "exs") {
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
            Image("sample")
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
        }.onDisappear {
            conductor.stop()
        }
    }
}
