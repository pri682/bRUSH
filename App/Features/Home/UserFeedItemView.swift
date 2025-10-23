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

    init(item: FeedItem) {
        self.item = item
        _goldCount = State(initialValue: item.medalGold)
        _silverCount = State(initialValue: item.medalSilver)
        _bronzeCount = State(initialValue: item.medalBronze)
    }

    // Resolve the displayed image exactly like your working screen does
    private var resolvedImage: UIImage? {
        if let name = item.artImageName, let img = UIImage(named: name) {
            return img
        }
        if let symbol = item.artSystemImageName, let img = UIImage(systemName: symbol) {
            return img
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
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

            // Artwork + actions row
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        Group {
                            if let image = resolvedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                // fallback placeholder if no image found
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .padding(48)
                            }
                        }
                    )
                    .clipped()

                HStack(spacing: 14) {
                    medalButton(systemName: "medal.fill", color: .yellow, count: $goldCount, isSelected: $goldSelected)
                    medalButton(systemName: "medal.fill", color: .gray, count: $silverCount, isSelected: $silverSelected)
                    medalButton(systemName: "medal.fill", color: .orange, count: $bronzeCount, isSelected: $bronzeSelected)
                    Spacer()
                    shareButton()
                        .disabled(resolvedImage == nil)
                        .opacity(resolvedImage == nil ? 0.4 : 1.0)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        // Present your existing ShareSheet exactly like the working screen
        .sheet(isPresented: $isSharing) {
            if let image = resolvedImage {
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
