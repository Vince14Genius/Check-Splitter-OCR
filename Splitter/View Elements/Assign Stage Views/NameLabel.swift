import SwiftUI

struct NameLabel: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text.isEmpty ? "No Name" : text)
            .foregroundColor(text.isEmpty ? Color(.tertiaryLabel) : .primary)
    }
}