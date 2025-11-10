import UIKit
import CoreImage
import SwiftUI

extension UIImage {
    
    private func averageColor() async -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: CGFloat(bitmap[3]) / 255.0)
    }
    
    func getGradientColors() async -> (UIColor, UIColor, UIColor) {
        guard let avgColor = await self.averageColor() else {
            return (.systemGray, .systemGray2, .systemGray3)
        }
        
        let secColor = avgColor.shifted(by: 0.1)
        let terColor = avgColor.shifted(by: -0.1)
        
        return (avgColor, secColor, terColor)
    }
}


extension UIColor {
    
    var isDark: Bool {
        var a: CGFloat = 0
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return false
        }
        
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance < 0.5
    }
    
    func shifted(by amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }
        
        var newHue = (hue + amount).truncatingRemainder(dividingBy: 1.0)
        if newHue < 0 {
            newHue += 1.0
        }
        
        let newSaturation = min(1.0, saturation * 1.1)
        
        return UIColor(hue: newHue,
                       saturation: newSaturation,
                       brightness: brightness,
                       alpha: alpha)
    }
}
