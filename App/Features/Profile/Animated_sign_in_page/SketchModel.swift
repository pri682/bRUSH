//
//  Sketch.swift
//  brush
//
//  Created by Meidad Troper on 10/10/25.
//


import SwiftUI

struct Sketch: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    let speed: Double
}
