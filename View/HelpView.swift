//
//  HelpView.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/20.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    let helpText = [
        """
        In music theory, an interval is a difference in pitch between two sounds. An interval may be described as horizontal, linear, or melodic if it refers to successively sounding tones, such as two adjacent pitches in a melody, and vertical or harmonic if it pertains to simultaneously sounding tones, such as in a chord.
        """,
        """
        The Interval Fairy grows into intervals made through the piano keys or stars. Press the piano keys or stars in pairs. An interval between two notes is found. A fairy satisfies her hunger by catching a star.
        """,
        """
        And there are Major, minor, Perfect, Augmented, diminished types of intervals. This is called quality. Depending on the quality of each interval, the Interval Fairy can feel good, clear, or healthy. Or vice versa.
        """,
        """
        Press the speaker button to hear what the interval sounds like. Also, if you press the View Detail button, a detailed description of the interval is provided. You can check the fairy's current status by pressing the View Status button.
        """,
        """
        Let's find many intervals to make a fairy happy.
        """,
    ]
    
    var body: some View {
        VStack {
            TabView {
                HelpPageView(imageName: "Help_1", content: helpText[0])
                HelpPageView(imageName: "Help_2", content: helpText[1])
                HelpPageView(imageName: "Help_3", content: helpText[2])
                HelpPageView(imageName: "Help_4", content: helpText[3])
                HelpPageView(imageName: "Help_5", content: helpText[4])
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Spacer()
            
            HStack {
                Button("Skip Help/Tutorial") {
                    dismiss()
                }.buttonStyle(.borderedProminent)
            }
            Spacer().frame(height: 30)
        }.padding(sides: [.left, .right], value: 30)
        
    }
}

struct HelpPageView: View {
    @State var imageName: String
    @State var content: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
            Spacer().frame(height: 30)
            Text(content)
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
