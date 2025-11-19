//
//  ShareCardGeneratorView.swift
//  brush
//
//  Created by Meidad Troper on 11/18/25.
//


//
//  ShareCardGeneratorView.swift
//  brush
//
//  Created by Meidad Troper on 11/18/25.
//
import SwiftUI
struct ShareCardGeneratorView: View {
    let userProfile: UserProfile
    
    // MARK: - State for Customization
    // We lift the state up here so it persists between tabs
    @State private var currentTab: String = "Preview"
    
    // ✅ FIX: Add '?? .blue' to handle the optional Color
    @State private var backgroundColor: Color = Color(hex: "#1A237E") ?? .blue
    @State private var cardColor: Color = Color(hex: "#2A2A72") ?? .indigo
    
    let tabs = ["Preview", "Edit"]
    @Namespace private var animation
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Background Layer (Global)
            // This ensures the background color is behind everything, even the nav bar
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Main Content Area
                ZStack {
                    if currentTab == "Preview" {
                        ShareCardPreviewView(
                            backgroundColor: $backgroundColor,
                            cardColor: $cardColor
                        )
                        .transition(.opacity)
                    } else {
                        ShareCardEditView(
                            backgroundColor: $backgroundColor,
                            cardColor: $cardColor
                        )
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // We add animation to the View switching
                .animation(.easeInOut(duration: 0.3), value: currentTab)
            }
            
            // MARK: - Liquid Glass Navigation Bar
            // Floating on top of the content
            VStack {
                HStack {
                    // Close Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Liquid Glass Segmented Control
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(currentTab == tab ? .black : .white.opacity(0.7))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background {
                                    if currentTab == tab {
                                        Capsule()
                                            .fill(Color.white)
                                            .matchedGeometryEffect(id: "activeTab", in: animation)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        currentTab = tab
                                    }
                                }
                        }
                    }
                    .padding(4)
                    .background(.ultraThinMaterial) // The "Liquid Glass" effect
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 0.5)
                    )
                    
                    Spacer()
                    
                    // Invisible spacer to balance the Close button centered layout
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}


