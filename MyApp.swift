import SwiftUI

@main
struct MyApp: App {
    init() {
        // TODO: - 앱 설치 시 초기화
        // let trigger = true
        // if UserDefaults.standard.bool(forKey: "FIRST_RUN") || trigger {
        //     let status = StatusManager.shared
        //     status.age = 0
        //     status.augDim = 5000
        //     status.discipline = 10000
        //     status.happy = 5000
        //     status.health = 10000
        //     status.hygiene = 5000
        //     status.perfectness = 0
        //     status.satiety = 5000
        //     status.weight = 10000
        //
        // }
        print("MyApp: init ========")
        
        FontManager.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
