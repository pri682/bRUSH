import SwiftUI
import Combine

struct CustomExportAnimation: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            // Darker overlay for better contrast
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // The Bar Loader
                BarLoaderView()
                    .frame(height: 80)
                    .offset(y: -20)
                
                // Text Area
                VStack(spacing: 8) {
                    Text("Generating Video")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                        .contentTransition(.numericText(value: progress * 100))
                        .animation(.default, value: progress)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

struct BarLoaderView: View {
    let barCount = 9
    let barWidth: CGFloat = 10
    let spacing: CGFloat = 10 // 20px left increment - 10px width = 10px gap
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { index in
                BarView(delay: Double(index) * 0.15)
            }
        }
    }
}

struct BarView: View {
    let delay: Double
    
    @State private var height: CGFloat = 30
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color(hex: "#ff6a00") ?? .orange)
            .frame(width: 10, height: height)
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    Animation
                        .easeInOut(duration: 0.75) // Half of 1.5s
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    height = 70
                    offsetY = 35
                }
            }
    }
}
