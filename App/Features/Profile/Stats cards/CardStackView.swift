//
//  CardStackView.swift
//  brush
//
//  Created by Meidad Troper on 10/15/25.
//

import SwiftUI

struct CardStackView: View {
    let cards: [CardItem<AnyView>]
    @State private var topCardIndex: Int = 0
    // 🔄 dragOffset tracks horizontal movement
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimating = false
    
    // 🔧 Card motion parameters
    private let swipeTravelDistance: CGFloat = 220 // horizontal distance the card moves when swiped
    private let swipeThreshold: CGFloat = 80       // minimum horizontal drag before swipe triggers
    private let animationSpeed: Double = 0.02      // overall swipe duration (smaller = faster)
    
    // 🌟 Stacking Visual Parameters (remains the same for the stacked visual)
    private let stackRotation: Double = -3 // Rotation for the card underneath (left tilt)
    private let stackYOffset: CGFloat = 15 // Vertical offset for the card underneath
    
    var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.1.id) { index, card in
                let isTopCard = index == topCardIndex
                let isCardBehind = index == (topCardIndex + 1) % cards.count
                let offset = isTopCard ? dragOffset : .zero
                
                card.content
                    .frame(maxWidth: .infinity)
                    
                    // MARK: - STACKING EFFECT
                    // Top card rotates based on horizontal drag (offset.width)
                    .rotationEffect(.degrees(isTopCard ? Double(offset.width / 15) : (isCardBehind ? stackRotation : 0)), anchor: .bottom)
                    
                    // Apply horizontal drag offset for top card (offset.width)
                    // Back card uses only vertical stack offset
                    .offset(x: isTopCard ? offset.width : 0,
                            y: isTopCard ? 0 : (isCardBehind ? stackYOffset : CGFloat(index - topCardIndex) * 10))
                    
                    .scaleEffect(isTopCard ? 1.0 : (isCardBehind ? 0.95 : 0.90))
                    .opacity(isTopCard ? 1.0 : (isCardBehind ? 0.85 : 0.0))
                    
                    .animation(.spring(response: 0.35, dampingFraction: 0.78), value: dragOffset)
                    .zIndex(isTopCard ? 1 : (isCardBehind ? 0.5 : 0))
                    
                    // MARK: - HORIZONTAL DRAG GESTURE
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if isTopCard && !isAnimating {
                                    dragOffset = gesture.translation
                                }
                            }
                            .onEnded { gesture in
                                guard isTopCard else { return }
                                // 🔄 Check horizontal swipe threshold (gesture.translation.width)
                                if abs(gesture.translation.width) > swipeThreshold {
                                    swipeCard(direction: gesture.translation.width < 0 ? .left : .right)
                                } else {
                                    // 🔁 Snap back to center
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
        
        // 🔄 Travel distance is horizontal
        let travel = direction == .left ? -swipeTravelDistance : swipeTravelDistance
        
        // 💨 Main swipe animation speed and smoothness
        withAnimation(.interpolatingSpring(stiffness: 160, damping: 14)) {
            // Apply horizontal travel (width: travel, height: 0)
            dragOffset = CGSize(width: travel, height: 0)
        }
        
        // ⏱ Controls how long before switching to the next card (speed of card cycle)
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed) {
            withAnimation(.easeInOut(duration: 0.22)) {
                dragOffset = .zero
                // If swiping right (forward), cycle to next card. If swiping left (backward), cycle to previous card.
                if direction == .right {
                    topCardIndex = (topCardIndex + 1) % cards.count
                } else { // .left
                    // Safely calculates the previous index in a circular array
                    topCardIndex = (topCardIndex - 1 + cards.count) % cards.count
                }
                isAnimating = false
            }
        }
    }
}

// 🔄 Updated directions
enum SwipeDirection {
    case left, right
}

struct CardItem<Content: View>: Identifiable {
    let id = UUID()
    let content: Content
}
