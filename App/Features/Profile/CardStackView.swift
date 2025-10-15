//
//  CardStackView.swift
//  brush
//
//  Created by Meidad Troper on 10/15/25.
//

import SwiftUI

struct CardStackView<CardContent: View>: View {
    let cards: [CardItem<CardContent>]
    @State private var topCardIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimating = false
    
    // 🔧 Card motion parameters
    private let swipeTravelDistance: CGFloat = 220 // distance the card moves when swiped (shorter = less travel)
    private let swipeThreshold: CGFloat = 80       // minimum drag before swipe triggers
    private let animationSpeed: Double = 0.02      // overall swipe duration (smaller = faster)
    
    var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.1.id) { index, card in
                let isTopCard = index == topCardIndex
                let offset = isTopCard ? dragOffset : .zero
                
                card.content
                    .frame(maxWidth: .infinity)
                    .rotationEffect(.degrees(isTopCard ? Double(offset.height / 15) : 0)) // slight rotation effect while dragging
                    .offset(y: isTopCard ? offset.height : CGFloat(index - topCardIndex) * 10) // small stacking offset
                    .scaleEffect(isTopCard ? 1.0 : 0.96)
                    .opacity(isTopCard ? 1.0 : 0.85)
                    .animation(.spring(response: 0.35, dampingFraction: 0.78), value: dragOffset) // speed of live drag motion
                    .zIndex(isTopCard ? 1 : 0)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if isTopCard && !isAnimating {
                                    dragOffset = gesture.translation
                                }
                            }
                            .onEnded { gesture in
                                guard isTopCard else { return }
                                if abs(gesture.translation.height) > swipeThreshold {
                                    swipeCard(direction: gesture.translation.height < 0 ? .up : .down)
                                } else {
                                    // 🔁 Snap back to center (speed of bounce-back)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
            }
        }
    }
    
    private func swipeCard(direction: SwipeDirection) {
        guard !isAnimating else { return }
        isAnimating = true
        
        // 🔧 Reduced swipe distance and faster motion
        let travel = direction == .up ? -swipeTravelDistance : swipeTravelDistance
        
        // 💨 Main swipe animation speed and smoothness
        withAnimation(.interpolatingSpring(stiffness: 160, damping: 14)) { // higher stiffness = faster movement
            dragOffset = CGSize(width: 0, height: travel)
        }
        
        // ⏱ Controls how long before switching to the next card (speed of card cycle)
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed) {
            withAnimation(.easeInOut(duration: 0.22)) { // transition speed between cards
                dragOffset = .zero
                topCardIndex = (topCardIndex + 1) % cards.count
                isAnimating = false
            }
        }
    }
}

enum SwipeDirection {
    case up, down
}

struct CardItem<Content: View>: Identifiable {
    let id = UUID()
    let content: Content
}
