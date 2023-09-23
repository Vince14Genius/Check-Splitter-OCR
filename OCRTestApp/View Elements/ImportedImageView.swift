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
            Centered {
                ProgressView()
            }
        case .empty:
            Centered {
                VStack {
                    Image(systemName: "text.viewfinder")
                        .font(.title)
                        .padding(.bottom)
                    Text("Scan a receipt from your Photo Library")
                        .font(.headline)
                    Text("Or enter items manually")
                }
            }
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
