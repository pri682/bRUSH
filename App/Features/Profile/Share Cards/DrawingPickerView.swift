//
//  DrawingPickerView.swift
//  brush
//
//  Created by Meidad Troper on 11/23/25.
//

import SwiftUI

struct DrawingPickerView: View {
    @EnvironmentObject var dataModel: DataModel
    @Binding var selectedDrawing: Item?
    @Binding var isPresented: Bool
    
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                if dataModel.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No drawings yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Create your first drawing to use it on a card")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 20) {
                            ForEach(dataModel.items) { item in
                                Button(action: {
                                    if item.image != nil {
                                        selectedDrawing = item
                                        isPresented = false
                                    }
                                }) {
                                    ZStack {
                                        if let image = item.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 100, height: 100)
                                                .overlay(ProgressView())
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    // Load image if not already loaded (like GridItemView)
                                    if item.image == nil {
                                        dataModel.loadImage(for: item.id)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Choose Drawing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
