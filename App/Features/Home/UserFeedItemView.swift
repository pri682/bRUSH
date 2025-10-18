import SwiftUI
import UIKit

struct UserFeedItemView: View {
    let item: FeedItem
    // When false, the post should be visually redacted/blurred for the user
    var isRevealed: Bool = true

    @State private var goldCount: Int
    @State private var silverCount: Int
    @State private var bronzeCount: Int
    @State private var goldSelected: Bool = false
    @State private var silverSelected: Bool = false
    @State private var bronzeSelected: Bool = false
    @State private var resolvedUIImage: UIImage? = nil

    init(item: FeedItem, isRevealed: Bool = true) {
        self.item = item
        self.isRevealed = isRevealed
        _goldCount = State(initialValue: item.medalGold)
        _silverCount = State(initialValue: item.medalSilver)
        _bronzeCount = State(initialValue: item.medalBronze)
    }

    var body: some View {
    VStack(alignment: .leading, spacing: 12) {
            // Header: profile + name/username
            HStack(alignment: .center, spacing: 12) {
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
            
            // Art area (vertical canvas placeholder for now)
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16.0/9.0, contentMode: .fit)
                    .overlay(
                        Group {
                            if isRevealed {
                                if let ui = resolvedUIImage {
                                    Image(uiImage: ui)
                                        .resizable()
                                        .scaledToFill()
                                } else if let url = item.artImageURL, FileManager.default.fileExists(atPath: url.path) {
                                    // load the local image only when revealed
                                    Color.clear.onAppear {
                                        loadImage(from: url)
                                    }
                                } else if let name = item.artImageName, UIImage(named: name) != nil {
                                    Image(name)
                                        .resizable()
                                        .scaledToFill()
                                } else if let artSymbol = item.artSystemImageName {
                                    Image(systemName: artSymbol)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                        .padding(48)
                                }
                            } else {
                                // Not revealed: show a neutral placeholder (no real image load)
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                                    .padding(48)
                            }
                        }
                    )
                    .clipped()

                // Medal icons and counts at bottom-left (interactive)
                HStack(spacing: 14) {
                    medalButton(systemName: "medal.fill", color: .yellow, count: $goldCount, isSelected: $goldSelected)
                    medalButton(systemName: "medal.fill", color: .gray, count: $silverCount, isSelected: $silverSelected)
                    medalButton(systemName: "medal.fill", color: .orange, count: $bronzeCount, isSelected: $bronzeSelected)
                }
                .padding(12)
            }
        }
        .redacted(reason: isRevealed ? [] : .placeholder)
    }

    @ViewBuilder
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
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(UIColor.systemBackground).opacity(isSelected.wrappedValue ? 1.0 : 0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected.wrappedValue ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private extension UserFeedItemView {
    func loadImage(from url: URL) {
        // Avoid reloading if already set
        guard resolvedUIImage == nil else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    resolvedUIImage = image
                }
            }
        }
    }
}

#Preview {
    UserFeedItemView(item: FeedItem(
        displayName: "Preview User",
        username: "@preview",
        profileSystemImageName: "person.circle.fill",
        artSystemImageName: "photo.on.rectangle.angled",
        artImageName: nil, artImageURL: nil,
        medalGold: 3,
        medalSilver: 2,
        medalBronze: 1,
        upVotes: 100,
        downVotes: 5,
        comments: 42,
        awards: 0
    ))
    .padding()
}
