import SwiftUI

// MARK: - MedalRowView
struct MedalRowView: View {
    let title: String
    let count: Int
    let imageName: String
    let countColor: Color
    let medalIconSize: CGFloat
    let fontScalingFactor: CGFloat
    
    private let baseLeadingPadding: CGFloat = 20
    private let baseTrailingPadding: CGFloat = 20
    private let baseCountTopPadding: CGFloat = 10
    private let baseMedalTopOffset: CGFloat = -25
    
    // MARK: - Number Formatting Functions
    
    private func formatNumber(_ number: Int) -> (display: String, subtitle: String?) {
        if number == -1 {
            return ("--", nil)
        }
        
        if number >= 1_000_000 {
            let millions = Double(number) / 1_000_000
            let display = millions.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(millions))M" : String(format: "%.1fM", millions)
            return (display, "\(number)")
        } else if number >= 1_000 {
            let thousands = Double(number) / 1_000
            let display = thousands.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(thousands))K" : String(format: "%.1fK", thousands)
            return (display, "\(number)")
        } else {
            return ("\(number)", nil)
        }
    }
    
    private func calculateFontSize(for number: Int, baseSize: CGFloat, scaling: CGFloat) -> CGFloat {
        let numberString = "\(number)"
        let characterCount = numberString.count
        
        // Scale down font size based on character count
        if characterCount <= 4 {
            return baseSize
        } else if characterCount <= 6 {
            return baseSize * 0.85
        } else if characterCount <= 8 {
            return baseSize * 0.75
        } else {
            return baseSize * 0.65
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let scaling = isIpad ? 0.9 : 1.0  // Reduce iPad scaling to prevent overlap
            
            HStack(alignment: .top) {
                // Count + Title
                VStack(alignment: .leading, spacing: 2 * fontScalingFactor) {
                    let formattedNumber = formatNumber(count)
                    let baseFontSize = (65 * fontScalingFactor * scaling) * 1.1
                    let dynamicFontSize = calculateFontSize(for: count, baseSize: baseFontSize, scaling: scaling)
                    
                    Text(formattedNumber.display)
                        .font(.system(size: dynamicFontSize, weight: .bold))
                        .foregroundColor(countColor)
                    
                    // Show subtitle if we have an abbreviated number
                    if let subtitle = formattedNumber.subtitle {
                        Text(subtitle)
                            .font(.system(size: 14 * fontScalingFactor * scaling))
                            .foregroundColor(.black.opacity(0.5))
                    }
                    
                    Text(title)
                        .font(.system(size: 16 * fontScalingFactor * scaling))
                        .foregroundColor(.black.opacity(0.65))
                }
                .padding(.top, baseCountTopPadding * fontScalingFactor)
                
                Spacer()
                
                // Medal Image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: medalIconSize * scaling, height: medalIconSize * scaling)
                    .alignmentGuide(.top) { d in d[.top] }
                    .padding(.trailing, baseTrailingPadding * fontScalingFactor)
                    .padding(.top, baseMedalTopOffset)
            }
            .padding(.leading, baseLeadingPadding * fontScalingFactor)
        }
    }
}
