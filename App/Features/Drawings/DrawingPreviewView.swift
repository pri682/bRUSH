//
//  DrawingPreviewView.swift
//  brush
//
//  Created by Kelvin Mathew on 9/28/25.
//


import SwiftUI

struct DrawingPreviewView: View {
    let item: Item
    @State private var isSharing = false
    
    var body: some View {
        Group {
            if let previewImage = item.preview {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                // This fallback shows while the preview is being generated after launch.
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isSharing = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $isSharing) {
            // This uses your existing ShareSheet.swift file
            if let imageToShare = item.preview {
                ShareSheet(activityItems: [imageToShare])
            }
        }
    }
}