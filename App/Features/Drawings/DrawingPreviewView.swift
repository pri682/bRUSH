import SwiftUI

struct DrawingPreviewView: View {
    let item: Item
    
    @State private var isSharing = false
    @State private var rotationAngle: Double = -10
    @State private var isAnimating = true
    @GestureState private var dragOffset: CGSize = .zero
    @State private var accumulatedRotation: Double = 0
    
    private var formattedDate: String {
        item.date.formatted(date: .long, time: .omitted)
    }
    
    private var resolvedImage: UIImage? {
        if let img = item.image {
            return img
        } else if let data = try? Data(contentsOf: item.url),
                  let img = UIImage(data: data) {
            return img
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if let image = resolvedImage {
                ZStack(alignment: .bottom) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .shadow(radius: 10, y: 5)
                        .rotation3DEffect(
                            .degrees(rotationAngle + dragOffset.width),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.35
                        )
                        .gesture(
                            DragGesture()
                                .updating($dragOffset, body: { (value, state, _) in
                                    state = value.translation
                                })
                                .onChanged({ _ in
                                    isAnimating = false
                                })
                                .onEnded({ value in
                                    self.rotationAngle += value.translation.width
                                    self.accumulatedRotation = self.rotationAngle
                                    isAnimating = true
                                    startAnimation()
                                })
                        )
                    
                    VStack(spacing: 12) {
                        Text(item.prompt)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 25)
                    .glassEffect(.regular.interactive())
                    .offset(y: -20)
                }
                .padding()
                .navigationTitle(formattedDate)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.isSharing = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(isPresented: $isSharing) {
                    let itemSource = ImageActivityItemSource(title: item.prompt, image: image)
                    ShareSheet(
                        activityItems: [itemSource]
                    )
                }
                .onAppear(perform: startAnimation)
            } else {
                ProgressView()
                    .navigationTitle("Loading...")
            }
        }
    }
    
    private func startAnimation() {
        guard isAnimating else { return }
        
        let targetAngle = rotationAngle > 0 ? -10.0 : 10.0
        
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            rotationAngle = targetAngle
        }
    }
}

