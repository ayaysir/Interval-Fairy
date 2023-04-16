import SwiftUI
import AudioKit
import SoundpipeAudioKit
import AudioKitUI
import Keyboard
import PopupView

class InstrumentEXSConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = MIDISampler(name: "Instrument 1")
    var displayKey: Key = .C
    @Published var intervalDescription: String = ""
    @Published var notesDescription: String = ""
    
    private(set) var note1: Note?
    private(set) var note2: Note?

    func noteOn(pitch: Pitch, point _: CGPoint) {
        // print(Date(), MusicNote.fromMIDINoteNumber(pitch.midiNoteNumber))
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
        if note1 == nil {
            note1 = Note(pitch: Pitch(pitch.midiNoteNumber), key: displayKey)
            notesDescription = note1!.description
        } else if note2 == nil {
            note2 = Note(pitch: Pitch(pitch.midiNoteNumber), key: displayKey)
            notesDescription = "\(note1!.description) and \(note2!.description)"
        }
        
    }

    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
        
        if let note1 = note1, let note2 = note2 {
            let descBefore = notesDescription
            
            notesDescription = descBefore + " = \n..."
            if let interval = Tonic.Interval.betweenNotes(note1, note2) {
                // 음정 판정 부분
                // Status 조정
                // if emergency { ... } else { adjust status }
                intervalDescription = interval.longDescription
                let quality = interval.longDescription.split(separator: " ")[0]
                
                notesDescription = descBefore + " = \n\(intervalDescription)"
                print(quality)
                
                // TODO: - Status 증가 여부를 표시 (화면 구석에 애니메이팅된 텍스트로)
                StatusManager.shared.discipline += 100
                StatusManager.shared.satiety += 100
                
                switch quality {
                case "Perfect":
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.hygiene += 5000
                    StatusManager.shared.health += 100
                    StatusManager.shared.perfectness += 1000
                case "Major":
                    StatusManager.shared.happy += Int.random(in: 1000...2000)
                    StatusManager.shared.health += 100
                case "Minor":
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.health -= 100
                case "Augmented":
                    StatusManager.shared.age += 40
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.hygiene += 5000
                    StatusManager.shared.health -= 100
                    StatusManager.shared.augDim += Int.random(in: 500...1000)
                case "Diminished":
                    StatusManager.shared.age -= 40
                    StatusManager.shared.happy -= 1000
                    StatusManager.shared.health -= 100
                    StatusManager.shared.augDim -= Int.random(in: 500...1000)
                default:
                    break
                }
                
                // StatusManager.shared.printAllStatus()
            } else {
                notesDescription = descBefore + " = \n?"
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

struct ContentView: View {
    @StateObject var conductor = InstrumentEXSConductor()
    
    let keyList: [Key] = [.C, .Db, .D, .Eb, .E, .F, .Gb, .G, .Ab, .A, .Bb, .B]
    @State var currentKeyIndex = 0
    @State private var isDisplayFlat = false
    
    @State private var showFallStar = false
    
    @StateObject var starVM = StarViewModel(maxCapacity: 5)
    @StateObject var tamagotchiMovingVM = TamagotchiMovingViewModel()
    
    @State var appeared: [Bool] = [false, false, false, false, false]
    @State var elapsedSeconds = [0, 0, 0, 0, 0]
    
    @State var showStatusPopup = false
    @State var blurMainArea = false
    
    @State var statusTimer: Timer?
    @State var lastRecordedTime: Date?
    
    @Environment(\.scenePhase) var scenePhase
    
    private var keyTextIndex: Int {
        if currentKeyIndex == keyList.count - 1 {
            return currentKeyIndex + (isDisplayFlat ? -1 : 0)
        }
        
        return currentKeyIndex + (isDisplayFlat ? 1 : 0)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)
                HStack {
                    Button {
                        showStatusPopup = true
                        blurMainArea = true
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
                    // Rect Area
                    ZStack(alignment: .bottom) {
                        // Background
                        Rectangle()
                            .fill(.cyan)
                            
                        // Balloon
                        if !conductor.notesDescription.isEmpty {
                            ZStack(alignment: .topLeading) {
                                // RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                //     .fill(.white)
                                Image("balloon")
                                    .resizable()
                                Text(conductor.notesDescription)
                                    .offset(x: 25, y: 15)
                            }
                            .offset(x: 100, y: -300)
                            .frame(width: 150, height: 100)
                        }
                        
                        // Tamagotchi
                        Image("sample4")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .offset(tamagotchiMovingVM.offset)
                    }
                    // Stars
                    ForEach(0..<5) { index in
                        StarView(conductor: conductor, starVM: starVM, index: index) {
                            elapsedSeconds[index] = 0
                            StatusManager.shared.satiety += 1000
                            let weight = StatusManager.shared.weight
                            if weight == 0 {
                                StatusManager.shared.weight = 10000
                            } else {
                                StatusManager.shared.weight += Int(Double(weight) * 0.1)
                            }
                            
                            // StatusManager.shared.printAllStatus()
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.8)
                
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
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                }
            }
            .blur(radius: blurMainArea ? 20 : 0)
            // Popup
            if showStatusPopup {
                ZStack {
                    Color(red: 0, green: 0, blue: 0, opacity: 0.3)
                    VStack(alignment: .leading) {
                        /*
                         // visible
                         static let stkAge = "STATUS_AGE"
                         static let stkWeight = "STATUS_WEIGHT"
                         static let stkDiscipline = "STATUS_DISCIPLINE"
                         static let stkSatiety = "STATUS_SATIETY"
                         static let stkHappy = "STATUS_HAPPY"
                         
                         // invisible
                         static let stkHelath = "STATUS_HEALTH"
                         static let sktHygiene = "STATUS_HYGIENE"
                         static let stkPerfectness = "STATUS_PERFECTNESS"
                         static let stkAugDim = "STATUS_AUGDIM"
                         */
                        VStack {
                            HStack {
                                Text("AGE")
                                    .font(.title)
                                Spacer()
                                Text(StatusManager.shared.ageDescription)
                            }
                            .padding(20)
                            Divider()
                        }
                        VStack {
                            HStack {
                                Text("WEIGHT")
                                    .font(.title)
                                Spacer()
                                Text(StatusManager.shared.weightDescription)
                                    
                            }
                            .padding(20)
                            Divider()
                        }
                        VStack {
                            HStack {
                                Text("DISCIPLINE")
                                    .font(.title)
                                Spacer()
                                ProgressView(value: Double(StatusManager.shared.discipline), total: 10000)
                                    .progressViewStyle(.linear)
                                    .frame(width: 300)
                            }
                            .padding(20)
                            Divider()
                        }
                        VStack {
                            HStack {
                                Text("HUNGRY")
                                    .font(.title)
                                Spacer()
                                ProgressView(value: Double(StatusManager.shared.satiety), total: 10000)
                                    .progressViewStyle(.linear)
                                    .frame(width: 300)
                            }
                            .padding(20)
                            Divider()
                        }
                        VStack {
                            HStack {
                                Text("HAPPY")
                                    .font(.title)
                                Spacer()
                                ProgressView(value: Double(StatusManager.shared.happy), total: 10000)
                                    .progressViewStyle(.linear)
                                    .frame(width: 300)
                            }
                            .padding(20)
                            Divider()
                        }
                        Text(StatusManager.shared.allStatus)
                    }
                    .background(.white)
                    .cornerRadius(15)
                    .frame(minWidth: 0, idealWidth: 750, maxWidth: 750, minHeight: 0)
                    .shadow(radius: 10)
                    .onTapGesture {
                        print("위에")
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 1.2)
                .onTapGesture {
                    print("오버레이 닫기")
                    showStatusPopup = false
                    blurMainArea = false
                }
            } // if showPopup end
            
        } // Root Zstack End
        .onAppear {
            print("ContentView: OnAppear ========")
            conductor.start()
            print(Bundle.main)
            
            // StatusManager.shared.calculate(startDate: Date(timeIntervalSince1970: 1681653643))
            
            tamagotchiMovingVM.moveNormal()
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
                self.elapsedSeconds[index] = 0
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                for (i, _) in elapsedSeconds.enumerated() {
                    elapsedSeconds[i] += 1
                    
                    if !appeared[i] && elapsedSeconds[i] == (3 + (i * 15)) {
                        starVM.startAnimation(playIndex: i)
                        elapsedSeconds[i] = 0
                        appeared[i] = true
                    }
                    
                    if appeared[i] && starVM.hideStar[i] && elapsedSeconds[i] == 11 {
                        starVM.startAnimation(playIndex: i)
                        elapsedSeconds[i] = 0
                    }
                }
            }
        }.onDisappear {
            print("ContentView: OnDisappear ========")
            conductor.stop()
        }.onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                print("Background")
                statusTimer?.invalidate()
                UserDefaults.standard.set(Date(), forKey: "STORE_lastRecordedTime")
            case .inactive:
                print("Inactive")
            case .active:
                print("Active")
                initStatusTimer()
            @unknown default:
                break
            }
        }
    }
    
    func initStatusTimer() {
        // 타이머 등록시 시각
        if let savedLastRecordTime = UserDefaults.standard.object(forKey: "STORE_lastRecordedTime") as? Date {
            lastRecordedTime = savedLastRecordTime
            UserDefaults.standard.set(nil, forKey: "STORE_lastRecordedTime")
        } else {
            lastRecordedTime = Date()
        }
        
        // 타이머 등록
        statusTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            guard let lastRecordedTime = lastRecordedTime else {
                return
            }
            StatusManager.shared.calculate(startDate: lastRecordedTime)
            print("statusTimer is validate!")
            self.lastRecordedTime = Date()
            UserDefaults.standard.set(Date(), forKey: "STORE_lastRecordedTime")
        }
    }
}
