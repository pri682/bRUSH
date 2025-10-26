import SwiftUI
import UIKit

struct UserFeedItemView: View {
    let item: FeedItem

    @State private var goldCount: Int
    @State private var silverCount: Int
    @State private var bronzeCount: Int
    @State private var goldSelected = false
    @State private var silverSelected = false
    @State private var bronzeSelected = false

    @State private var isSharing = false
    @State private var sharedImage: UIImage?

    init(item: FeedItem) {
        self.item = item
        _goldCount = State(initialValue: item.medalGold)
        _silverCount = State(initialValue: item.medalSilver)
        _bronzeCount = State(initialValue: item.medalBronze)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header
            HStack(spacing: 12) {
                Image(systemName: item.profileSystemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.username)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            // MARK: - Artwork + Medal actions
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        AsyncImage(url: URL(string: item.imageURL)) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    Rectangle().fill(Color(UIColor.secondarySystemBackground))
                                    ProgressView()
                                }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .onAppear {
                                        // Convert to UIImage for sharing later
                                        let renderer = ImageRenderer(content: image)
                                        if let uiImage = renderer.uiImage {
                                            sharedImage = uiImage
                                        }
                                    }
                            case .failure:
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .padding(48)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .clipped()
                    )

                // Medal + Share buttons
                HStack(spacing: 14) {
                    medalButton(systemName: "medal.fill", color: .yellow, count: $goldCount, isSelected: $goldSelected)
                    medalButton(systemName: "medal.fill", color: .gray, count: $silverCount, isSelected: $silverSelected)
                    medalButton(systemName: "medal.fill", color: .orange, count: $bronzeCount, isSelected: $bronzeSelected)
                    Spacer()
                    shareButton()
                        .disabled(sharedImage == nil)
                        .opacity(sharedImage == nil ? 0.4 : 1.0)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $isSharing) {
            if let image = sharedImage {
                let itemSource = ImageActivityItemSource(
                    title: "Check out this drawing from \(item.displayName)!",
                    image: image
                )
                ShareSheet(activityItems: [itemSource])
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Medal button
    private func medalButton(systemName: String, color: Color, count: Binding<Int>, isSelected: Binding<Bool>) -> some View {
        Button {
            if isSelected.wrappedValue {
                isSelected.wrappedValue = false
                count.wrappedValue = max(0, count.wrappedValue - 1)
            } else {
                isSelected.wrappedValue = true
                count.wrappedValue += 1
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemName)
                    .foregroundColor(color)
                Text("\(count.wrappedValue)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground).opacity(isSelected.wrappedValue ? 1.0 : 0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected.wrappedValue ? Color.accentColor : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Share button (same styling as medals)
    private func shareButton() -> some View {
        Button {
            isSharing = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
                Text("Share")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground).opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
