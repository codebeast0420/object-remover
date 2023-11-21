//
//  Extensions.swift
//  Avatarly
//
//  Created by Shahid Iqbal on 16/08/2023.
//

import Foundation
import SwiftUI
import Vision

//extension Notification.Name{
//    static let PurchaseSucceedNotification = Notification.Name(rawValue: PurchaseStatus.shared.PurchaseSucceed)
//}

extension UIImage {
    func resizeImage(maxHeight: Float? = 2000, maxWidth: Float? = 2000) -> UIImage {
        var actualHeight: Float = Float(self.size.height)
        var actualWidth: Float = Float(self.size.width)
        let maxHeight = maxHeight!
        let maxWidth = maxWidth!
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRectMake(0.0, 0.0, CGFloat(actualWidth), CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData = img.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
    }
    
    func fixOrientation() -> UIImage? {

            if (imageOrientation == .up) { return self }

            var transform = CGAffineTransform.identity

            switch imageOrientation {
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: size.width, y: 0.0)
                transform = transform.rotated(by: .pi / 2.0)
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0.0, y: size.height)
                transform = transform.rotated(by: -.pi / 2.0)
            case .down, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: size.height)
                transform = transform.rotated(by: .pi)
            default:
                break
            }

            switch imageOrientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: 0.0)
                transform = transform.scaledBy(x: -1.0, y: 1.0)
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: size.height, y: 0.0)
                transform = transform.scaledBy(x: -1.0, y: 1.0)
            default:
                break
            }

            guard let cgImg = cgImage else { return nil }

            if let context = CGContext(data: nil,
                                       width: Int(size.width), height: Int(size.height),
                                       bitsPerComponent: cgImg.bitsPerComponent,
                                       bytesPerRow: 0, space: cgImg.colorSpace!,
                                       bitmapInfo: cgImg.bitmapInfo.rawValue) {

                context.concatenate(transform)

                if imageOrientation == .left || imageOrientation == .leftMirrored ||
                    imageOrientation == .right || imageOrientation == .rightMirrored {
                    context.draw(cgImg, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
                } else {
                    context.draw(cgImg, in: CGRect(x: 0.0 , y: 0.0, width: size.width, height: size.height))
                }

                if let contextImage = context.makeImage() {
                    return UIImage(cgImage: contextImage)
                }

            }

            return nil
        }
}

extension CGImage {
    func faceCrop(margin: CGFloat = 100, completion: @escaping (FaceCropResult) -> Void) {
        let req = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
                return
            }
            
            guard let results = request.results, !results.isEmpty else {
                completion(.notFound)
                return
            }
            
            var faces: [VNFaceObservation] = []
            for result in results {
                guard let face = result as? VNFaceObservation else { continue }
                faces.append(face)
            }
            let facesArr = self.getCropping(for: faces, margin: margin)
            if facesArr.count>0 {
                // 12
                completion(.success(facesArr))
            } else {
                completion(.notFound)
            }
            
            
        }
#if targetEnvironment(simulator)
        req.usesCPUOnly = true
#endif
        
        do {
            try VNImageRequestHandler(cgImage: self, options: [:]).perform([req])
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func getCropping(for faces: [VNFaceObservation], margin: CGFloat) -> [(image: UIImage, frame: CGRect)] {
        var croppedImagesWithFrames: [(image: UIImage, frame: CGRect)] = []

        for face in faces {
            let w = face.boundingBox.width * CGFloat(width)
            let h = face.boundingBox.height * CGFloat(height)
            let x = face.boundingBox.origin.x * CGFloat(width)
            let y = (1 - face.boundingBox.origin.y) * CGFloat(height) - h * 1.2

            let scaleRatio = 1.5
            let new_w = w * scaleRatio
            let new_h = h * scaleRatio
            let new_x = x - w * (scaleRatio - 1) / 2
            let new_y = y - h * (scaleRatio - 1) / 2

            let faceRect = CGRect(x: new_x, y: new_y, width: new_w, height: new_h)

            if let faceImage = self.cropping(to: faceRect) {
                croppedImagesWithFrames.append((image: UIImage(cgImage: faceImage), frame: faceRect))
            }
        }

        return croppedImagesWithFrames
    }

    
    func faceDetect(margin: CGFloat = 100,completion: @escaping (FaceDetectResult) -> Void) {
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                completion(.faceNotFounded)
                print(error.localizedDescription)
                return
            }
            
            guard let results = request.results, !results.isEmpty else {
                completion(.faceNotFounded)
                return
            }
            
            // Faces were detected
            var faces: [VNFaceObservation] = []
            for result in results {
                guard let face = result as? VNFaceObservation else { continue }
                faces.append(face)
            }
            let facesArr = self.getCropping(for: faces, margin: margin)
            if facesArr.count>0 {
                // 12
                completion(.faceFounded)
            } else {
                completion(.faceNotFounded)
            }
        }
        
#if targetEnvironment(simulator)
        request.usesCPUOnly = true
#endif

        do {
            try VNImageRequestHandler(cgImage: self, options: [:]).perform([request])
        } catch let error {
            completion(.faceNotFounded)
            print(error.localizedDescription)
        }
    }
    
}

struct VisualEffectView: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

extension UIDevice {
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

public enum FaceCropResult {
    case success([(image: UIImage, frame: CGRect)])
    case notFound
    case failure(Error)
}


public enum FaceDetectResult {
    case faceFounded
    case faceNotFounded
}
