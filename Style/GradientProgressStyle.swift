//
//  GradientProgressStyle.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/13.
//

import SwiftUI

struct GradientProgressStyle<Stroke: ShapeStyle, Background: ShapeStyle>: ProgressViewStyle {
    var stroke: Stroke
    var fill: Background
    var caption: String = ""
    var cornerRadius: CGFloat = 10
    var height: CGFloat = 20
    var animation: Animation = .easeInOut
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        return VStack {
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    Rectangle()
                        .fill(fill)
                        .frame(maxWidth: geo.size.width * CGFloat(fractionCompleted))
                        .animation(animation)
                }
            }
            .frame(height: height)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(stroke, lineWidth: 1)
            )
            
            if !caption.isEmpty {
                Text("\(caption)")
                    .font(.caption)
            }
        }
    }
}

