import SwiftUI

struct UserFeedItemView_Copy: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: profile + name/username
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: item.profileSystemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
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
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16.0/9.0, contentMode: .fit)
                    .overlay(
                        Group {
                            if let artSymbol = item.artSystemImageName {
                                Image(systemName: artSymbol)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                                    .padding(48)
                            }
                        }
                    )
                
                // Medal icons and counts at bottom-left
                HStack(spacing: 14) {
                    medalView(systemName: "medal.fill", color: .yellow, count: item.medalGold)
                    medalView(systemName: "medal.fill", color: .gray, count: item.medalSilver)
                    medalView(systemName: "medal.fill", color: .orange, count: item.medalBronze)
                }
                .padding(12)
            }
        }
    }

    @ViewBuilder
    private func medalView(systemName: String, color: Color, count: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .foregroundColor(color)
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(UIColor.systemBackground).opacity(0.85))
        )
    }
}

#Preview {
    UserFeedItemView_Copy(item: FeedItem(
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
