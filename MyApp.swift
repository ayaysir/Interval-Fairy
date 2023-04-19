import SwiftUI
import AVFoundation

@main
struct MyApp: App {
    init() {
        // UserDefaults.standard.set(true, forKey: .cfgIsNotFirstrun)
        if !UserDefaults.standard.bool(forKey: .cfgIsNotFirstrun) {
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
    static let cfgIsNotFirstrun = "CONFIG_IS_NOT_FIRSTRUN"
}
