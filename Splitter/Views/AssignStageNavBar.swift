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
    @Binding var path: [InfoEntryStage]
    @Environment(\.layoutDirection) private var layoutDirection
    
    var body: some View {
        HStack {
            Button("Back") {
                path.removeLast()
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
                stage = .calculated
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isNextButtonEnabled)
            .keyboardShortcut(.return, modifiers: .command)
        }
    }
}

#Preview {
    AssignStageNavBar(isNextButtonEnabled: true, stage: .constant(.infoEntry), path: .constant([.assignPayers]))
}
