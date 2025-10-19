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
                            
                            VStack(spacing: 12) {
                                Text(formattedDate)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .glassEffect(.regular.interactive())

                                Text(item.prompt)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 25)
                                    .glassEffect(.regular.interactive())
                            }
                            .offset(y: -20)
                        }
                        .padding()
                        .padding(.top, 30)
                        .onAppear(perform: startAnimation)
                        
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
