import Foundation

struct Friend: Identifiable, Hashable, Equatable {
    let id = UUID()
    let uid: String
    let name: String
    let handle: String
    let profileImageURL: String?
}
