import SwiftUI

enum AvatarLayer {
    case body
    case head
}

struct PoppingAvatarView: View {
    let profile: UserProfile
    let layer: AvatarLayer
    
    var body: some View {
        let avatarType = AvatarType(rawValue: profile.avatarType) ?? .personal

        ZStack {
            switch layer {
            case .body:
                if avatarType == .personal {
                    if let avatarBody = profile.avatarBody {
                        Image(avatarBody)
                            .resizable()
                            .scaledToFit()
                    }
                    if let shirt = profile.avatarShirt {
                        Image(shirt)
                            .resizable()
                            .scaledToFit()
                    }
                } else {
                    if let face = profile.avatarBody {
                        Image(face)
                            .resizable()
                            .scaledToFit()
                    }
                }
            
            case .head:
                if let eyes = profile.avatarEyes {
                    Image(eyes)
                        .resizable()
                        .scaledToFit()
                        .offset(x: 0, y: 60)
                }
                if let facialHair = profile.avatarFacialHair {
                    Image(facialHair)
                        .resizable()
                        .scaledToFit()
                        .offset(x: 0, y: 60)
                }
                if let mouth = profile.avatarMouth {
                    Image(mouth)
                        .resizable()
                        .scaledToFit()
                        .offset(x: 0, y: 60)
                }
                if let hair = profile.avatarHair {
                    Image(hair)
                        .resizable()
                        .scaledToFit()
                        .offset(x: 0, y: 60)
                }
            }
        }
    }
}
