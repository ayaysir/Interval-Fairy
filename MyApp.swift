import SwiftUI
import AVFoundation

@main
struct MyApp: App {
    init() {
        if UserDefaults.standard.bool(forKey: "FIRST_RUN") {
            StatusManager.shared.initializeStatus()
        }
        
        FontManager.registerFonts()
        
        // 무음모드에서 소리가 나게 하기
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // print error...
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension String {
    static let fontDG = "NeoDunggeunmoPro-Regular"
}
