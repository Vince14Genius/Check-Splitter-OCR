//
//  OCRBottomBar.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct OCRBottomBar: View {
    let items: [Item]
    let ocrResults: [OCRResult]
    @Binding var isShowingOCRLabels: Bool
    @Binding var zoomScale: OCRResultsFrame.ZoomScale
    @Binding var viewModel: OCRPhotoModel
    
    var body: some View {
        VStack(spacing: 0) {
            if !ocrResults.isEmpty {
                HStack(spacing: 0) {
                    FloatingButton {
                        isShowingOCRLabels.toggle()
                    } label: {
                        Image(systemName: isShowingOCRLabels ? "eye" : "eye.slash")
                    }
                    Divider()
                    FloatingButton {
                        zoomScale = zoomScale.next()
                    } label: {
                        Label("\(zoomScale.rawValue)x", systemImage: "plus.magnifyingglass")
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                        .stroke(.primary.opacity(0.1))
                )
                .padding()
            }
            Divider()
            HStack {
                if !ocrResults.isEmpty {
                    ImagePicker(selection: $viewModel.imageSelection)
                    Spacer()
                    Button("Next") {
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(items.isEmpty)
                } else {
                    Spacer()
                    ImagePicker(selection: $viewModel.imageSelection)
                    Spacer()
                }
            }
            .padding()
            .background(.regularMaterial)
        }
    }
}

private struct FloatingButton<T: View>: View {
    let action: () -> Void
    let label: () -> T
    
    var body: some View {
        Button {
            action()
        } label: {
            label()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
    }
}

#Preview {
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
