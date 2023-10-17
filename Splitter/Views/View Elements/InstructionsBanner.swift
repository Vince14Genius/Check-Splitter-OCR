//
//  InstructionsBanner.swift
//  Splitter
//
//  Created by Vincent C. on 9/24/23.
//

import SwiftUI

struct InstructionsBanner: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .padding(10)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.thinMaterial)
                .stroke(.primary.opacity(0.1))
        )
    }
}

#Preview {
    VStack {
        InstructionsBanner(text: "Instructions text\nInstructions text line 2")
        InstructionsBanner(text: "A much much much much much much longer instructions text line 3")
    }
    .padding()
}
