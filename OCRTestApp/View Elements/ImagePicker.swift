//
//  ImagePicker.swift
//  OCRTestApp
//
//  Created by Vincent C. on 8/30/23.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var selection: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selection,
                     matching: .images,
                     photoLibrary: .shared()) {
            Label {
                Text("Pick Image")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .buttonStyle(.bordered)
    }
}
