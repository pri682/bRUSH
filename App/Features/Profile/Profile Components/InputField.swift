import SwiftUI
import Combine
import FirebaseAuth

struct InputField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let hasError: Bool
    let textContentType: UITextContentType?
    
    init(placeholder: String, text: Binding<String>, isSecure: Bool = false, hasError: Bool = false, textContentType: UITextContentType? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.hasError = hasError
        self.textContentType = textContentType
    }

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType ?? .password)
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(textContentType ?? .emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(hasError ? Color.red : Color.clear, lineWidth: 2)
        )
        .shadow(radius: 1)
    }
}
