import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1 // Allow selecting only 1 image
        let pickerController = PHPickerViewController(configuration: configuration)
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Nothing to update here
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image, isPresented: $isPresented)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var image: UIImage?
        @Binding var isPresented: Bool

        init(image: Binding<UIImage?>, isPresented: Binding<Bool>) {
            self._image = image
            self._isPresented = isPresented
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (loadedImage, error) in
                    if let image = loadedImage as? UIImage {
                        DispatchQueue.main.async {
                            self.image = image.fixOrientation()
                            self.isPresented = false
                        }
                    }
                }
            } else {
                // Handle the case where no valid image was selected
                self.isPresented = false
            }
        }
    }
}
