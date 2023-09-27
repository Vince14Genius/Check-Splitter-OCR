//
//  ImagePicker.swift
//  Splitter
//
//  Created by Vincent C. on 8/30/23.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var selection: PhotosPickerItem?
    
    private var hasSelection: Bool { selection != nil }
    
    var body: some View {
        if hasSelection {
            PhotosPicker(selection: $selection,
                         matching: .images,
                         photoLibrary: .shared()) {
                Label("Repick Image", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.bordered)
        } else {
            PhotosPicker(selection: $selection,
                         matching: .images,
                         photoLibrary: .shared()) {
                Label("Pick Image", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
