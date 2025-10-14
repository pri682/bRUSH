import SwiftUI
import UIKit

struct UserFeedItemView: View {
    let item: FeedItem

    @State private var goldCount: Int
    @State private var silverCount: Int
    @State private var bronzeCount: Int
    @State private var goldSelected: Bool = false
    @State private var silverSelected: Bool = false
    @State private var bronzeSelected: Bool = false

    init(item: FeedItem) {
        self.item = item
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
                            if let name = item.artImageName, UIImage(named: name) != nil {
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

#Preview {
    UserFeedItemView(item: FeedItem(
        displayName: "Preview User",
        username: "@preview",
        profileSystemImageName: "person.circle.fill",
        artSystemImageName: "photo.on.rectangle.angled",
        artImageName: nil,
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
