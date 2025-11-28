import SwiftUI

struct CardStackView: View {
    let cards: [CardItem<AnyView>]
    @State private var topCardIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimating = false
    
    private let swipeTravelDistance: CGFloat = 220
    private let swipeThreshold: CGFloat = 80
    private let animationSpeed: Double = 0.02
    
    private let stackYOffset: CGFloat = 25
    private let sideCardOffset: CGFloat = 40
    private let sideCardScale: CGFloat = 0.85
    private let sideCardOpacity: CGFloat = 0.75
    
    var body: some View {
        ZStack {
            ForEach(0..<cards.count, id: \.self) { index in
                let card = cards[index]
                let isTopCard = index == topCardIndex
                
                let cardOffset = calculateCardOffset(for: index, dragOffset: dragOffset)
                let cardRotation = calculateCardRotation(for: index, dragOffset: dragOffset)
                let cardScale = calculateCardScale(for: index)
                let cardOpacity = calculateCardOpacity(for: index)
                let cardZIndex = calculateCardZIndex(for: index)
                
                card.content
                    .frame(maxWidth: .infinity)
                    .rotationEffect(.degrees(cardRotation), anchor: .center)
                    .offset(x: cardOffset.width, y: cardOffset.height)
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .zIndex(cardZIndex)
                    .shadow(
                        color: isTopCard ? .clear : .black.opacity(0.15),
                        radius: isTopCard ? 0 : 8,
                        x: isTopCard ? 0 : 2,
                        y: isTopCard ? 0 : 4
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: topCardIndex)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if isTopCard && !isAnimating {
                                    dragOffset = gesture.translation
                                }
                            }
                            .onEnded { gesture in
                                guard isTopCard else { return }
                                if abs(gesture.translation.width) > swipeThreshold {
                                    let direction = gesture.translation.width < 0 ? SwipeDirection.left : SwipeDirection.right
                                    if canSwipe(direction: direction) {
                                        swipeCard(direction: direction)
                                    } else {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                            dragOffset = .zero
                                        }
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
            }
        }
    }
    
    private func calculateCardOffset(for index: Int, dragOffset: CGSize) -> CGSize {
        let isTopCard = index == topCardIndex
        let isNextCard = index == topCardIndex + 1 && topCardIndex < cards.count - 1
        let isPrevCard = index == topCardIndex - 1 && topCardIndex > 0
        
        if isTopCard {
            return dragOffset
        } else if isNextCard {
            return CGSize(width: sideCardOffset + dragOffset.width * 0.3, height: stackYOffset)
        } else if isPrevCard {
            return CGSize(width: -sideCardOffset + dragOffset.width * 0.3, height: stackYOffset)
        } else {
            return CGSize(width: 0, height: stackYOffset * 2)
        }
    }
    
    private func calculateCardRotation(for index: Int, dragOffset: CGSize) -> Double {
        let isTopCard = index == topCardIndex
        let isNextCard = index == topCardIndex + 1 && topCardIndex < cards.count - 1
        let isPrevCard = index == topCardIndex - 1 && topCardIndex > 0
        
        if isTopCard {
            return Double(dragOffset.width / 20)
        } else if isNextCard {
            return 3 + Double(dragOffset.width / 30)
        } else if isPrevCard {
            return -3 + Double(dragOffset.width / 30)
        } else {
            return 0
        }
    }
    
    private func calculateCardScale(for index: Int) -> CGFloat {
        let isTopCard = index == topCardIndex
        let isNextCard = index == topCardIndex + 1 && topCardIndex < cards.count - 1
        let isPrevCard = index == topCardIndex - 1 && topCardIndex > 0
        
        if isTopCard {
            return 1.0
        } else if isNextCard || isPrevCard {
            return sideCardScale
        } else {
            return 0.8
        }
    }
    
    private func calculateCardOpacity(for index: Int) -> Double {
        let isTopCard = index == topCardIndex
        let isNextCard = index == topCardIndex + 1 && topCardIndex < cards.count - 1
        let isPrevCard = index == topCardIndex - 1 && topCardIndex > 0
        
        if isTopCard {
            return 1.0
        } else if isNextCard || isPrevCard {
            return sideCardOpacity
        } else {
            return 0.0
        }
    }
    
    private func calculateCardZIndex(for index: Int) -> Double {
        let isTopCard = index == topCardIndex
        let isNextCard = index == topCardIndex + 1 && topCardIndex < cards.count - 1
        let isPrevCard = index == topCardIndex - 1 && topCardIndex > 0
        
        if isTopCard {
            return 3.0
        } else if isNextCard {
            return 2.0
        } else if isPrevCard {
            return 1.0
        } else {
            return 0.0
        }
    }
    
    private func canSwipe(direction: SwipeDirection) -> Bool {
        switch direction {
        case .left: return topCardIndex < cards.count - 1
        case .right: return topCardIndex > 0
        }
    }
    
    private func swipeCard(direction: SwipeDirection) {
        guard !isAnimating else { return }
        isAnimating = true
        
        let travel = direction == .left ? -swipeTravelDistance : swipeTravelDistance
        
        withAnimation(.interpolatingSpring(stiffness: 160, damping: 14)) {
            dragOffset = CGSize(width: travel, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed) {
            withAnimation(.easeInOut(duration: 0.22)) {
                dragOffset = .zero
                if direction == .right {
                    topCardIndex = max(0, topCardIndex - 1)
                } else {
                    topCardIndex = min(cards.count - 1, topCardIndex + 1)
                }
                isAnimating = false
            }
        }
    }
}

// Enums define a *finite set of possible values* that a variable can take.
// Here, SwipeDirection can only ever be `.left` or `.right` — no other cases.
enum SwipeDirection {
    case left, right
}

// Generic struct that wraps any type of View content as a “card”.
// The `<Content: View>` syntax means it can hold *any* view type.
struct CardItem<Content: View>: Identifiable {
    // Each card has a unique ID used by SwiftUI for animation and diffing.
    let id = UUID()
    
    // The view that represents the actual card content.
    let content: Content
}
