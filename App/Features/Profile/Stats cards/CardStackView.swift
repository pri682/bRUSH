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
    
    // 🌟 Enhanced Stacking Visual Parameters for Apple Messages style
    private let stackRotation: Double = -8 // More pronounced rotation for cards behind
    private let stackYOffset: CGFloat = 25 // More vertical offset for better separation
    private let sideCardOffset: CGFloat = 40 // Horizontal offset for side cards
    private let sideCardScale: CGFloat = 0.85 // Scale for side cards
    private let sideCardOpacity: CGFloat = 0.75 // Increased opacity for better visibility
    
    var body: some View {
        ZStack {
            ForEach(0..<cards.count, id: \.self) { index in
                let card = cards[index]
                let isTopCard = index == topCardIndex
                let isNextCard = index == (topCardIndex + 1) % cards.count
                let isPrevCard = index == (topCardIndex - 1 + cards.count) % cards.count
                let isVisibleCard = isTopCard || isNextCard || isPrevCard
                
                // Calculate card position relative to current top card
                let cardOffset = calculateCardOffset(for: index, dragOffset: dragOffset)
                let cardRotation = calculateCardRotation(for: index, dragOffset: dragOffset)
                let cardScale = calculateCardScale(for: index)
                let cardOpacity = calculateCardOpacity(for: index)
                let cardZIndex = calculateCardZIndex(for: index)
                
                card.content
                    .frame(maxWidth: .infinity)
                    
                    // MARK: - ENHANCED STACKING EFFECT
                    .rotationEffect(.degrees(cardRotation), anchor: .center)
                    .offset(x: cardOffset.width, y: cardOffset.height)
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .zIndex(cardZIndex)
                    
                    // Add subtle shadow to side cards for better visibility
                    .shadow(
                        color: isTopCard ? .clear : .black.opacity(0.15),
                        radius: isTopCard ? 0 : 8,
                        x: isTopCard ? 0 : 2,
                        y: isTopCard ? 0 : 4
                    )
                    
                    // Add subtle background tint to side cards
                    .background(
                        isTopCard ? Color.clear : Color.white.opacity(0.1)
                    )
                    
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: topCardIndex)
                    
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
                                    let direction = gesture.translation.width < 0 ? SwipeDirection.left : SwipeDirection.right
                                    // Check if we can swipe in this direction (not at boundaries)
                                    if canSwipe(direction: direction) {
                                        swipeCard(direction: direction)
                                    } else {
                                        // Can't swipe further, snap back to center
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                            dragOffset = .zero
                                        }
                                    }
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
    
    // MARK: - Card Position Calculation Functions
    
    private func calculateCardOffset(for index: Int, dragOffset: CGSize) -> CGSize {
        let isTopCard = index == topCardIndex
        let isNextCard = index == topCardIndex + 1 && topCardIndex < cards.count - 1
        let isPrevCard = index == topCardIndex - 1 && topCardIndex > 0
        
        if isTopCard {
            // Top card follows drag gesture
            return dragOffset
        } else if isNextCard {
            // Next card peeks from the right
            return CGSize(
                width: sideCardOffset + dragOffset.width * 0.3,
                height: stackYOffset
            )
        } else if isPrevCard {
            // Previous card peeks from the left
            return CGSize(
                width: -sideCardOffset + dragOffset.width * 0.3,
                height: stackYOffset
            )
        } else {
            // Hidden cards
            return CGSize(width: 0, height: stackYOffset * 2)
        }
    }
    
    private func calculateCardRotation(for index: Int, dragOffset: CGSize) -> Double {
        let isTopCard = index == topCardIndex
        let isNextCard = index == topCardIndex + 1 && topCardIndex < cards.count - 1
        let isPrevCard = index == topCardIndex - 1 && topCardIndex > 0
        
        if isTopCard {
            // Top card rotates based on drag
            return Double(dragOffset.width / 20)
        } else if isNextCard {
            // Next card has slight right rotation
            return 3 + Double(dragOffset.width / 30)
        } else if isPrevCard {
            // Previous card has slight left rotation
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
    
    // MARK: - Boundary Check Function
    
    private func canSwipe(direction: SwipeDirection) -> Bool {
        switch direction {
        case .left:
            // Can swipe left if we're not at the last card
            return topCardIndex < cards.count - 1
        case .right:
            // Can swipe right if we're not at the first card
            return topCardIndex > 0
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
                // Linear progression: no circular wrapping
                if direction == .right {
                    // Swipe right = go to previous card (backward)
                    topCardIndex = max(0, topCardIndex - 1)
                } else { // .left
                    // Swipe left = go to next card (forward)
                    topCardIndex = min(cards.count - 1, topCardIndex + 1)
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
