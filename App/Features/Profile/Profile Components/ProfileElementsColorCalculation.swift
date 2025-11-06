//
//  ProfileElementsColorCalculation.swift
//  brush
//
//  Created by Meidad Troper on 11/5/25.
//
import SwiftUI
import UIKit // Required for UIImage and UIColor extensions
import CoreImage // Required for average color calculation

// MARK: - Profile Elements Color Calculation

struct ProfileElementsColorCalculation {
    
    /// Calculates the best contrasting text color (Black or White) and its corresponding shadow
    /// based on the average luminance of the provided background image asset.
    ///
    /// - Parameter backgroundName: The name of the image asset to analyze (e.g., "background_1").
    /// - Returns: A tuple containing the primary text Color and its contrasting shadow Color.
    static func calculateContrastingTextColor(for backgroundName: String) -> (color: Color, shadowColor: Color) {
        
        guard let backgroundUIImage = UIImage(named: backgroundName),
              let averageColor = backgroundUIImage.averageColor else {
            // Default to white text with a black shadow if the image cannot be loaded
            return (.white, .black)
        }
        
        // 1. Check if the color is bright using the publicly accessible helper.
        let isBright = averageColor.isBrightForTextContrast()
        
        // 2. Determine best contrasting text color (Black/White threshold)
        // If the background is bright, use black text.
        // If the background is dark, use white text.
        let textColor: Color = isBright ? .black : .white
        
        // 3. Shadow is the inverse of the text color for maximum pop.
        let shadowColor: Color = textColor == .white ? .black : .white
        
        return (textColor, shadowColor)
    }
}

// MARK: - Helper Extensions for Image/Color Analysis (Requires UIKit/CoreImage)

extension UIColor {
    // ❗ FIX: Made this function internal (no access modifier) so it can be called
    // from the static function above, while keeping luminance private.
    func isBrightForTextContrast() -> Bool {
        // Threshold for contrast: 0.6 luminance
        return self.luminance > 0.6
    }
    
    // 🔒 Keeps the raw luminance calculation private
    private var luminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Standard W3C formula
        return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
    }
}

extension UIImage {
    // Calculates the average color of the entire image efficiently using a CoreImage filter.
    var averageColor: UIColor? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let filter = CIFilter(name: "CIAreaAverage")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        let extent = ciImage.extent
        filter?.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        // Convert the RGBA bytes to a UIColor
        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: CGFloat(bitmap[3]) / 255.0
        )
    }
}
