//
//  Sketch.swift
//  brush
//
//  Created by Meidad Troper on 10/10/25.
//


import SwiftUI

struct Sketch: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let rotation: Double
    var opacity: Double
    var isFadingOut: Bool
    var color: Color = .white

    static func == (lhs: Sketch, rhs: Sketch) -> Bool {
        lhs.id == rhs.id
    }
}
