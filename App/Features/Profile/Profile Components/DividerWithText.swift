import SwiftUI
import Combine
import FirebaseAuth

struct DividerWithText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack {
            VStack { Divider() }
            Text(text)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
            VStack { Divider() }
        }
    }
}
