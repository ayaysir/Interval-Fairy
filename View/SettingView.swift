//
//  SettingView.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/19.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var fairyName: String
    
    @State var showResetAlert = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            Text("Settings").font(.largeTitle)
            Form {
                Group {
                    HStack {
                        Text("Enter Your Fairy's name:").fontWeight(.bold)
                        TextField("Fairy's Name", text: $fairyName)
                    }
                    // Button("Reset all data") {
                    //     showResetAlert = true
                    // }.foregroundColor(.red)
                    Text(
                        """
                        Licenses:
                        
                        * Musiqwik Font
                        Copyright (c) 2001, 2008 by Robert Allgeyer. SIL Open Font License.
                        
                        * Neo둥근모 Font
                        SIL Open Font License 1.1
                        
                        * AudioKit, AudioKitUI, Keyboard, SoundpipeAudioKit, Tonic
                        MIT License
                        https://github.com/audiokit
                        
                        * StableDiffusion
                        CreativeML Open RAIL-M
                        """
                    )
                }
            }
            Button("Dismiss") {
                dismiss()
            }.buttonStyle(.borderedProminent)
            Spacer().frame(height: 20)
        }.alert("Are you sure you want to reset all data in the app? This action cannot be undone.", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            Button("OK", role: .destructive) {
                
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(fairyName: .constant("Interval Gotchi"))
    }
}
