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
    
    var body: some View {
        GeometryReader { geometry in
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let scaling = isIpad ? 0.9 : 1.0  // Reduce iPad scaling to prevent overlap
            
            HStack(alignment: .top) {
                // Count + Title
                VStack(alignment: .leading, spacing: 2 * fontScalingFactor) {
                    Text(count == -1 ? "--" : "\(count)")
                        .font(.system(size: (65 * fontScalingFactor * scaling) * 1.1, weight: .bold))
                        .foregroundColor(countColor)
                    
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
