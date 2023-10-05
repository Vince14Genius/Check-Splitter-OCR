//
//  ResultsStageNavBar.swift
//  Splitter
//
//  Created by Vincent C. on 10/1/23.
//

import SwiftUI

struct ResultsStageNavBar: View {
    @Binding var stage: Stage
    @Binding var flowState: SplitterFlowState
    @Environment(\.layoutDirection) private var layoutDirection
    
    @State private var isPresentingStartOverAlert = false
    
    private func startOver() {
        stage = .receipt
        flowState = .init()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Button("Back") {
                    stage = .assignPayers
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
            .padding()
            .background(.thinMaterial)
        }
        .alert("Start Over?", isPresented: $isPresentingStartOverAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes, start over", role: .destructive) { startOver() }
        }
    }
}

#Preview {
    ResultsStageNavBar(stage: .constant(.calculated), flowState: .constant(.sampleData))
}
