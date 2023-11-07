//
//  ReceiptStageNavBar.swift
//  Splitter
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct ReceiptStageNavBar: View {
    let isNextButtonEnabled: Bool
    let areImagePickersNeeded: Bool
    @Binding var imagePickerItem: ImagePickerItem
    @Binding var path: [InfoEntryStage]
    
    var body: some View {
        HStack {
            if areImagePickersNeeded {
                CameraPicker(imageItem: $imagePickerItem)
                    .buttonStyle(.bordered)
                    .labelStyle(.iconOnly)
                PhotoLibraryPicker(imageItem: $imagePickerItem)
                    .labelStyle(.titleAndIcon)
            }
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
