import SwiftUI

struct DrawingPreviewView: View {
    let namespace: Namespace.ID
    let item: Item
    @Binding var selectedItem: Item?
    
    @State private var isSharing = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = true
    @GestureState private var dragOffset: CGSize = .zero
    @State private var accumulatedRotation: Double = 0
    
    @State private var showBubbles = false
    
    private var formattedDate: String {
        item.date.formatted(date: .long, time: .omitted)
    }
    
    private var resolvedImage: UIImage? {
        if let img = item.image {
            return img
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = documentsDirectory.appendingPathComponent(item.imageFileName)
        
        if let data = try? Data(contentsOf: imageUrl), let img = UIImage(data: data) {
            return img
        }
        
        return nil
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if let image = resolvedImage {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.clear)
                                .aspectRatio(9/16, contentMode: .fit)
                                .overlay(
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .aspectRatio(9/16, contentMode: .fit)
                                        .clipped()
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .matchedGeometryEffect(id: item.id, in: namespace)
                                .shadow(radius: 10, y: 5)
                                .rotation3DEffect(
                                    .degrees(rotationAngle + dragOffset.width),
                                    axis: (x: 0, y: 1, z: 0),
                                    perspective: 0.35
                                )
                                .gesture(
                                    DragGesture()
                                        .updating($dragOffset) { value, state, _ in
                                            state = value.translation
                                        }
                                        .onChanged { _ in
                                            isAnimating = false
                                        }
                                        .onEnded { value in
                                            rotationAngle += value.translation.width
                                            accumulatedRotation = rotationAngle
                                            isAnimating = true
                                            startAnimation()
                                        }
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showBubbles.toggle()
                                    }
                                }

                            VStack(spacing: 12) {
                                Text(formattedDate)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .glassEffect(.regular.interactive())

                                Text(item.prompt)
                                    .font(.system(size: 20, weight: .semibold))
//                                    .foregroundStyle(
//                                        LinearGradient(
//                                            colors: [
//                                                Color(red: 1.0, green: 0.35, blue: 0.2),
//                                                Color(red: 1.0, green: 0.25, blue: 0.25),
//                                                Color(red: 0.95, green: 0.4, blue: 0.15)
//                                            ],
//                                            startPoint: .bottomTrailing,
//                                            endPoint: .topLeading
//                                        )
//                                    )
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 25)
                                    .glassEffect(.regular.interactive())
                            }
                            .padding(.trailing, 25)
                            .padding(.leading, 25)
                            .offset(y: showBubbles ? -20 : 120)
                            .opacity(showBubbles ? 1 : 0)
                            .allowsHitTesting(false)
                        }
                        .padding()
                        .padding(.top, 30)
                        .onAppear {
                            startAnimation()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showBubbles = true
                                }
                            }
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedItem = nil
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.isSharing = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $isSharing) {
            if let image = resolvedImage {
                let itemSource = ImageActivityItemSource(title: item.prompt, image: image)
                ShareSheet(activityItems: [itemSource])
                    .presentationDetents([.medium, .large])
            }
        }
        .transition(.opacity)
    }
    
    private func startAnimation() {
        guard isAnimating else { return }
        let targetAngle = rotationAngle >= 0 ? 10.0 : -10.0
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            rotationAngle = targetAngle
        }
    }
}

