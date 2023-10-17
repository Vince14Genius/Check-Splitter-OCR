//
//  ResultsStageNavBar.swift
//  Splitter
//
//  Created by Vincent C. on 10/1/23.
//

import SwiftUI

struct ResultsStageNavBar: View {
    @Binding var stage: Stage
    @Binding var path: [InfoEntryStage]
    @Binding var flowState: SplitterFlowState
    @Environment(\.layoutDirection) private var layoutDirection
    
    @State private var isPresentingStartOverAlert = false
    
    private func startOver() {
        stage = .infoEntry
        path = []
        flowState = .init()
    }
    
    var body: some View {
        HStack {
            Button("Back") {
                stage = .infoEntry
            }
            .keyboardShortcut({
                switch layoutDirection {
                case .leftToRight: .leftArrow
                case .rightToLeft: .rightArrow
                @unknown default: .leftArrow
                }
            }(), modifiers: .command)
            Spacer()
            Button("Start Over") {
                isPresentingStartOverAlert = true
            }
            .buttonStyle(.bordered)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .alert("Start Over?", isPresented: $isPresentingStartOverAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes, start over", role: .destructive) { startOver() }
        }
    }
}

#Preview {
    ResultsStageNavBar(stage: .constant(.calculated), path: .constant([.assignPayers]), flowState: .constant(.sampleData))
}
