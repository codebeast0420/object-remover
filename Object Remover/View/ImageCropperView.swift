//
//  ImageCropper.swift
//  Avatarly
//
//  Created by Shahid Iqbal on 22/08/2023.
//

import SwiftUI
import Mantis

struct ImageCropperView: UIViewControllerRepresentable {
    @Binding var isShowing : Bool
    @Binding var image: UIImage?
    @State var cropShapeType: Mantis.CropShapeType
    @State var presetFixedRatioType: Mantis.PresetFixedRatioType
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: CropViewControllerDelegate {
        func cropViewControllerDidImageTransformed(_ cropViewController: CropViewController) {

        }

        var parent: ImageCropperView

        init(_ parent: ImageCropperView) {
            self.parent = parent
        }

        func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.image = cropped
            print("transformation is \(transformation)")
            parent.isShowing=false
//            parent.gotoImageEdit = true
//            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            parent.isShowing=false
//            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        }

        func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        }

        func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CropViewController {
        var config = Mantis.Config()
        config.cropShapeType = cropShapeType
        config.presetFixedRatioType = presetFixedRatioType
        let cropViewController = Mantis.cropViewController(image: image!,
                                                           config: config)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {

    }
}
