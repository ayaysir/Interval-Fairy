import SwiftUI
import AudioKit
import SoundpipeAudioKit
import AudioKitUI
import Keyboard

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
    
    @State var showIntervalInfo = false
    @State var showStatusAnimation = false
    @State var showStatusTextTimer: Timer?
    
    @State private var gradient = LinearGradient(
        gradient: Gradient(colors: [.green, .blue]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    @State private var isNeedDiscipline: Bool = false
    @State private var isNeedSatiety: Bool = false
    @State private var isNeedHappy: Bool = false
    @State private var isNeedHealth: Bool = false
    @State private var isNeedHygiene: Bool = false
    
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
                        showStatusAnimation = false
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }.padding([.leading, .trailing], 10)
                
                Spacer()
                
                // Tamagotchi area
                ZStack(alignment: .top) {
                    // 밑으로 갈수록 z-index 높음
                    
                    // Rect Area
                    ZStack(alignment: .bottom) {
                        // Background
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(.cyan)
                            
                            // status change popover
                            if showStatusAnimation {
                                Text(conductor.statusUpdateText)
                                .offset(x: 20, y: 20)
                                .font(.custom("NeoDunggeunmoPro-Regular", size: 30))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                // animation
                                
                            }
                        }
                        
                        // Balloon
                        if !conductor.notesDescription.isEmpty && conductor.showDescription {
                            ZStack(alignment: .topLeading) {
                                // RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                //     .fill(.white)
                                Image("balloon")
                                    .resizable()
                                VStack(alignment: .leading) {
                                    Text(conductor.notesDescription)
                                        .font(.system(size: 30, weight: .bold))
                                        // 글씨를 알아보기 어려움
                                        // .font(.custom("NeoDunggeunmoPro-Regular", size: 36))
                                    Spacer().frame(height: 10)
                                    if conductor.isIntervalCalculated {
                                        HStack {
                                            Button {
                                                conductor.playTwoNotes()
                                            } label: {
                                                Image(systemName: "speaker.wave.3.fill")
                                                    .font(.title)
                                            }
                                            Button {
                                                showIntervalInfo = true
                                            } label: {
                                                Text("View Detail")
                                                    .font(.title)
                                            }
                                        }
                                    }
                                }.offset(x: 70, y: 45)
                                
                            }
                            .offset(x: 250, y: -400)
                            .frame(width: 400, height: 300)
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
                        Color(red: 0.8, green: 0.8, blue: 0.8)
                        // Toolbar
                        HStack {
                            Image(systemName: "face.smiling")
                                .foregroundColor(isNeedHappy ? .black :  Color(white: 0.7))
                            Image(systemName: "fork.knife")
                                .foregroundColor(isNeedSatiety ? .black :  Color(white: 0.7))
                            Image(systemName: "shower")
                                .foregroundColor(isNeedHygiene ? .black :  Color(white: 0.7))
                            Image(systemName: "megaphone")
                                .foregroundColor(isNeedDiscipline ? .black :  Color(white: 0.7))
                            Image(systemName: "medical.thermometer")
                                .foregroundColor(isNeedHealth ? .black :  Color(white: 0.7))
                            Spacer()
                            Button("Toggle Sharp/Flat") {
                                isDisplayFlat.toggle()
                                conductor.displayKey = keyList[keyTextIndex]
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            Button("-") {
                                guard currentKeyIndex > 0 else {
                                    return
                                }
                                currentKeyIndex -= 1
                                isDisplayFlat = false
                            }
                            .buttonStyle(.borderedProminent)
                            Button {
                                currentKeyIndex = 0
                                isDisplayFlat = false
                            } label: {
                                Text("\(keyList[currentKeyIndex].textValue)")
                                    .frame(width: 80)
                            }
                            .buttonStyle(.borderedProminent)
                            Button("+") {
                                guard currentKeyIndex < keyList.count - 1 else {
                                    return
                                }
                                currentKeyIndex += 1
                                isDisplayFlat = false
                            }
                            .buttonStyle(.borderedProminent)
                        }.padding(sides: [.left, .right], value: 10)
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
                    VStack {
                        VStack(alignment: .leading) {
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
                                        .progressViewStyle(GradientProgressStyle(stroke: .gray, fill: gradient))
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
                                        .progressViewStyle(GradientProgressStyle(stroke: .gray, fill: gradient))
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
                                        .progressViewStyle(GradientProgressStyle(stroke: .gray, fill: gradient))
                                        .frame(width: 300)
                                }
                                .padding(20)
                                Divider()
                            }
                        }
                        Button {
                            showStatusPopup = false
                            blurMainArea = false
                        } label: {
                            Text("Close")
                        }
                        // Text(StatusManager.shared.allStatus)
                    }
                    .background(.white)
                    .cornerRadius(15)
                    .frame(minWidth: 0, idealWidth: 750, maxWidth: 750, minHeight: 0)
                    .shadow(radius: 10)
                    .onTapGesture {
                        // print("위에")
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 1.2)
                .onTapGesture {
                    // print("오버레이 닫기")
                    showStatusPopup = false
                    blurMainArea = false
                }
            } // if showPopup end
            
        } // Root Zstack End
        .onAppear {
            print("ContentView: OnAppear ========")
            conductor.start()
            print(Bundle.main)
            showStatusAnimation = true
            
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
            
            observeStatusNeed()
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
        }.sheet(isPresented: $showIntervalInfo) {
            if let note1 = conductor.note1, let note2 = conductor.note2 {
                IntervalInfoView(note1: note1, note2: note2, conductor: conductor)
            } else {
                Text("Interval Error")
            }
        }.onReceive(conductor.$statusUpdateText) { output in
            showStatusAnimation = true
            showStatusTextTimer?.invalidate()
            
            showStatusTextTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                self.showStatusAnimation = false
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
    
    func observeStatusNeed() {
        let status = StatusManager.shared
        isNeedHappy = status.isNeedHappy
        isNeedHealth = status.isNeedHealth
        isNeedHygiene = status.isNeedHygiene
        isNeedSatiety = status.isNeedSatiety
        isNeedDiscipline = status.isNeedDiscipline
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            isNeedHappy = status.isNeedHappy
            isNeedHealth = status.isNeedHealth
            isNeedHygiene = status.isNeedHygiene
            isNeedSatiety = status.isNeedSatiety
            isNeedDiscipline = status.isNeedDiscipline
        }
    }
}
