//
//  CameraPicker.swift
//  Splitter
//
//  Created by Vincent C. on 10/16/23.
//

import SwiftUI
import UIKit

struct CameraPicker: View {
    @Binding var imageItem: ImagePickerItem
    @State private var isPresentingCamera = false
    
    var body: some View {
        Button {
            isPresentingCamera = true
        } label: {
            Label("Camera", systemImage: "camera.fill")
        }
        .sheet(isPresented: $isPresentingCamera) {
            CameraView(imageItem: $imageItem, isPresented: $isPresentingCamera)
        }
    }
}

private struct CameraView: View {
    @Binding var imageItem: ImagePickerItem
    @Binding var isPresented: Bool
    
    var body: some View {
        #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        Text("Camera is not supported on this device")
            .foregroundStyle(.white)
            .background(.black)
        #else
        GeometryReader { proxy in
            let isPortrait = proxy.size.height > proxy.size.width
            if isPortrait {
                CameraViewInternal(imageItem: $imageItem, isPresented: $isPresented)
            } else {
                VStack {
                    Spacer()
                    Text("Camera is not available in landscape mode.")
                    .foregroundStyle(.white)
                    Spacer()
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .background(.black)
        #endif
    }
}

private struct CameraViewInternal: UIViewControllerRepresentable {
    @Binding var imageItem: ImagePickerItem
    @Binding var isPresented: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewInternal>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraViewInternal>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraViewInternal
        
        init(_ parent: CameraViewInternal) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.imageItem = .success(image: image)
            } else {
                parent.imageItem = .failure(CameraError.photoNotTaken)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

private enum CameraError: Error {
    case photoNotTaken
}
