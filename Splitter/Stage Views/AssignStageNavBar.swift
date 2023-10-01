//
//  AssignStageNavBar.swift
//  Splitter
//
//  Created by Vincent C. on 9/26/23.
//

import SwiftUI

struct AssignStageNavBar: View {
    let isNextButtonEnabled: Bool
    @Binding var stage: Stage
    @Environment(\.layoutDirection) private var layoutDirection
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Button("Back") {
                    stage = .receipt
                }
                .keyboardShortcut({
                    switch layoutDirection {
                    case .leftToRight: .leftArrow
                    case .rightToLeft: .rightArrow
                    @unknown default: .leftArrow
                    }
                }(), modifiers: .command)
                Spacer()
                Button("Calculate!") {
                    stage = .assignPayers
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isNextButtonEnabled)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding()
            .background(.thinMaterial)
        }
    }
}

#Preview {
    AssignStageNavBar(isNextButtonEnabled: true, stage: .constant(.assignPayers))
}
