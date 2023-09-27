//
//  OCRBottomBar.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct OCRBottomBar: View {
    let isNextButtonEnabled: Bool
    let isImageToolbarEnabled: Bool
    @Binding var isShowingOCRLabels: Bool
    @Binding var zoomScale: OCRResultsFrame.ZoomScale
    @Binding var viewModel: OCRPhotoModel
    
    var body: some View {
        VStack(spacing: 0) {
            if isImageToolbarEnabled {
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
                        Label("\(zoomScale.rawValue.formatted(.number.precision(.fractionLength(1))))x", systemImage: "plus.magnifyingglass")
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                )
                .padding()
            }
            Divider()
            HStack {
                ImagePicker(selection: $viewModel.imageSelection)
                Spacer()
                Button("Next") {
                    
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isNextButtonEnabled)
            }
            .padding()
            .background(.thinMaterial)
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
                .foregroundStyle(Color(.label))
        }
    }
}

#Preview {
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
