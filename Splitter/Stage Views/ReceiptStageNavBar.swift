//
//  ReceiptStageNavBar.swift
//  Splitter
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct ReceiptStageNavBar: View {
    let isNextButtonEnabled: Bool
    @Binding var viewModel: OCRPhotoModel
    @Binding var path: [InfoEntryStage]
    
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Label("Capture", systemImage: "camera.fill")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .disabled(true)
            ImagePicker(selection: $viewModel.imageSelection)
                .labelStyle(.titleAndIcon)
            Spacer()
            NavigationLink("Next", value: InfoEntryStage.assignPayers)
            .buttonStyle(.borderedProminent)
            .disabled(!isNextButtonEnabled)
            .keyboardShortcut(.return, modifiers: .command)
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
