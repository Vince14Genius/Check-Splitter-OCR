//
//  ImageViewerControls.swift
//  Splitter
//
//  Created by Vincent C. on 10/16/23.
//

import SwiftUI

struct ImageViewerControls: View {
    let isImageToolbarEnabled: Bool
    @Binding var isShowingOCRLabels: Bool
    @Binding var zoomScale: OCRResultsFrame.ZoomScale
    
    var body: some View {
        if isImageToolbarEnabled {
            HStack(spacing: 0) {
                Button {
                    isShowingOCRLabels.toggle()
                } label: {
                    Label(
                        isShowingOCRLabels ? "Hide OCR Labels" : "Show OCR Labels",
                        systemImage: isShowingOCRLabels ? "eye" : "eye.slash"
                    )
                    .labelStyle(.iconOnly)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .foregroundStyle(.primary)
                Divider()
                HStack {
                    Label("Zoom Scale", systemImage: "plus.magnifyingglass")
                        .labelStyle(.iconOnly)
                        .padding(.leading, 12)
                        .padding(.vertical, 8)
                    Picker(selection: $zoomScale) {
                        ForEach(OCRResultsFrame.ZoomScale.allCases, id: \.self) { scaleCase in
                            Text("\(scaleCase.rawValue.formatted(.number.precision(.fractionLength(1))))x")
                                .monospacedDigit()
                                .tag(scaleCase)
                        }
                    } label: {
                        Label("Zoom Scale", systemImage: "plus.magnifyingglass")
                            .labelStyle(.iconOnly)
                    }
                }
                .tint(.primary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
            )
            .padding()
        }
    }
}

#Preview {
    ImageViewerControls(isImageToolbarEnabled: true, isShowingOCRLabels: .constant(true), zoomScale: .constant(.zoom2x))
}
