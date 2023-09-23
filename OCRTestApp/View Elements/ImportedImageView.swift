//
//  ImportedImageView.swift
//  OCRTestApp
//
//  Created by Vincent C. on 8/30/23.
//

import SwiftUI

struct ImportedImageView: View {
    let imageState: OCRPhotoModel.ImageState
    
    var body: some View {
        switch imageState {
        case .success(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .loading:
            ProgressView()
        case .empty:
            Text("No image selected.")
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    Group {
        ImportedImageView(imageState: .empty)
        ImportedImageView(imageState: .loading(.init()))
    }
}
