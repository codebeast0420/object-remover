//
//  CZImageEditorViewModel.swift
//  TestingForPhotoEditor
//
//  Created by Kaiyi Zhao on 8/1/22.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import SwiftUICoreImage
import Combine

class CZImageEditorViewModel: ObservableObject {
    @Published var originImage: UIImage? = nil
    @Published var targetImage: UIImage? = nil
    @Published var filteredImages: [FilteredImage] = []
    var originFullImage: UIImage? = nil
    
    var frameSize: CGSize = .zero
    
    @Published var selectedFilter: CIFilter? = nil
    let context = CIContext()
    var filters: [CIFilter] = []
    
    @Published var CompareFlag = false // 判断是否执行过Inpaint/SR，显示Compare
    
    @Published var editingValue: Double = 0
//    @Published var savedEditingValue: Double = 0
    @Published var temp_savedEditingValue: [EditOption: Double] = Dictionary(uniqueKeysWithValues: EditOption.allCases.map { ($0, 0.0) })
    @Published var savedEditingValue: [EditOption: Double] = Dictionary(uniqueKeysWithValues: EditOption.allCases.map { ($0, 0.0) })
    // Editing values
    @Published var steadyPanOffset: CGSize = .zero
    @Published var steadyZoomScale: CGFloat = 1
    @Published var rotationPercent: Double = 0.5
    @Published var brightnessPercent: Double = 0.5
    @Published var contrastPercent: Double = 0.5
    @Published var saturationPercent: Double = 0.5
    @Published var sharpenPercent: Double = 0.5
    @Published var warmthPercent: Double = 0.5
    
    @Published var vignettePercent: Double = 0.0
    @Published var vibrancePercent: Double = 0.5
    @Published var exposurePercent: Double = 0.5
    @Published var clarityPercent: Double = 0.5

    
    var roundedZoomScale: Double {
        round(steadyZoomScale * 10000) / 10000.0
    }
    var rotatedAngle: Double {
        Angle(degrees: rotatedDegrees).radians
    }
    var rotatedDegrees: Double {
        EditOption.rotation.calculatedValue(percent: rotationPercent)
    }
    var initZoomScale: CGFloat {
        guard let originalPictureSize = originImage?.size else { return 1 }
        return frameSize.maxRatio(with: originalPictureSize)
    }
    
    func updateTempleSavedEditingValue(for option: EditOption, with value: Double) {
            temp_savedEditingValue[option] = value
    }
    
    func initializeVM(fullImage: UIImage, parameters: ImageEditorParameters, filters: [CIFilter], thumbnailMaxSize: CGFloat) async {
        let imageSize = fullImage.size
        let targetSize = imageSize * CGSize(width: thumbnailMaxSize, height: thumbnailMaxSize).minRatio(with: imageSize)
        
        if #available(iOS 15.0, *) {
            let editingImage = max(fullImage.size.width, fullImage.size.height) > thumbnailMaxSize ? await fullImage.byPreparingThumbnail(ofSize: targetSize) : fullImage
            
            await MainActor.run {
                originImage = editingImage
                targetImage = editingImage
                loadAttributes(attributes: parameters.attributes)
                applyFiltersToTarget()
            }
        } else {
            // Fallback on earlier versions
            let editingImage = max(fullImage.size.width, fullImage.size.height) > thumbnailMaxSize ?  resizeThumbnailImage(fullImage, targetSize: targetSize) : fullImage
            
            await MainActor.run {
                originImage = editingImage
                targetImage = editingImage
                loadAttributes(attributes: parameters.attributes)
                applyFiltersToTarget()
            }
        }
        
        self.filters = filters
        originFullImage = fullImage
    }
    
    // Slider max and min value setting
    func minSliderValue(option: EditOption) -> Double {
        switch option {
        case .vignette:
            return 0.0
        case .clarity:
            return 0.0
        default:
            return -100.0
        }
    }
    
    func maxSliderValue(option: EditOption) -> Double {
        switch option {
        case .vignette:
            return 100.0
        case .clarity:
            return 100.0
        default:
            return 100.0
        }
    }
    
    func resizeThumbnailImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize: CGSize

        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: rect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func loadAttributes(attributes: ImageEditorParameters.Attributes) {
        selectedFilter = attributes.appliedFilter
        steadyPanOffset = attributes.steadyPanOffset
        steadyZoomScale = attributes.steadyZoomScale
        rotationPercent = attributes.savedRotationPercent
        brightnessPercent = attributes.savedBrightnessPercent
        contrastPercent = attributes.savedContrastPercent
        saturationPercent = attributes.savedSaturationPercent
        sharpenPercent = attributes.savedSharpenPercent
        warmthPercent = attributes.savedWarmthPercent
        
        vignettePercent = attributes.savedvignettePercent
        vibrancePercent = attributes.savedvibrancePercent
        exposurePercent = attributes.savedexposurePercent
        clarityPercent = attributes.savedclarityPercent
    }
    
    func outputAttributes() -> ImageEditorParameters.Attributes {
        .init(appliedFilter: selectedFilter, steadyPanOffset: steadyPanOffset, steadyZoomScale: roundedZoomScale, savedRotationPercent: rotationPercent, savedBrightnessPercent: brightnessPercent, savedContrastPercent: contrastPercent, savedSaturationPercent: saturationPercent, savedSharpenPercent: sharpenPercent, savedWarmthPercent: warmthPercent, savedvignettePercent: vignettePercent, savedvibrancePercent: vibrancePercent, savedexposurePercent: exposurePercent, savedclarityPercent: clarityPercent)
    }
    
    func outputParameters() -> ImageEditorParameters {
        ImageEditorParameters(fullOriginalImage: originFullImage, attributes: outputAttributes())
    }
    
//    func loadFilterPreviews() async {
//        guard let originImage = originImage, let editImage = cropImage(originalImage: originImage, applyColorFilters: false) else { return }
//        await MainActor.run {
//            filteredImages.removeAll(keepingCapacity: true)
//        }
//        
//        let ciImage = CIImage(image: editImage)
//        
//        for (id, filter) in filters.enumerated() {
//            filter.setValue(ciImage, forKey: kCIInputImageKey)
//            guard let outputImage = filter.outputImage else { return }
//            
//            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
//                DispatchQueue.main.async { [weak self] in
//                    if self?.filteredImages.contains(where: { $0.id == id }) == false {
//                        let displayName = (filter.attributes[kCIAttributeFilterDisplayName] as? String) ?? "Unknown"
//                        self?.filteredImages.append(FilteredImage(id: id, image: UIImage(cgImage: cgimg), filter: filter, name: displayName))
//                    }
//                }
//            }
//        }
//    }
    
    func cropImage(originalImage: UIImage, applyColorFilters: Bool) -> UIImage? {
        guard frameSize != .zero, let alteredOriginalImage = applyColorFilters ? applyFilters(input: originalImage) : originalImage.rotate(radians: Float(rotatedAngle)),
              let cgImg = alteredOriginalImage.cgImage
        else { return nil }
        
//        print("alteredOriginalImage:\(alteredOriginalImage), orientation: \(originalImage.imageOrientation)")
        
        let fullWidth = alteredOriginalImage.size.width
        let editingWidth = targetImage?.size.width ?? fullWidth
        let extraScale = fullWidth / editingWidth
        

        let zoomScale = initZoomScale * steadyZoomScale / extraScale
        let panOffsetBeforeRotation = steadyPanOffset * extraScale
        let panOffset = panOffsetBeforeRotation.rotatedVector(radians: rotatedAngle)
        
        // adjust frame rect based on picture orientation
        let scaledFrameSize = frameSize / zoomScale
        
        var adjustedPanOffset: CGSize = panOffset
        switch originalImage.imageOrientation {
        case .up:
//            print("orientation: up 5") // checked
            break
        case .upMirrored:
//            print("orientation: upMirrored")
            adjustedPanOffset = panOffset.reverseWidth()
        case .down:
//            print("orientation: down") // checked
            adjustedPanOffset = panOffset.reverseWidthHeight()
        case .downMirrored:
//            print("orientation: downMirrored")
            adjustedPanOffset = panOffset.reverseHeight()
        case .left:
//            print("orientation: left") // checked
            adjustedPanOffset = panOffset.rotatedVector(radians: Double.pi / 2)
        case .leftMirrored:
//            print("orientation: leftMirrored")
            adjustedPanOffset = panOffset.rotatedVector(radians: Double.pi / 2).reverseWidth()
        case .right:
//            print("orientation: right") // checked
            adjustedPanOffset = panOffset.rotatedVector(radians: -Double.pi / 2)
        case .rightMirrored:
//            print("orientation: rightMirrored")
            adjustedPanOffset = panOffset.rotatedVector(radians: -Double.pi / 2).reverseWidth()
        @unknown default: break
        }
//        print("panOffset: \(panOffset), adjustedPanOffset: \(adjustedPanOffset)")
        
        var adjustedPicCenter = alteredOriginalImage.size.center
        var adjustedFrameSize = scaledFrameSize
        switch originalImage.imageOrientation {
        case .up, .upMirrored, .down, .downMirrored: break
        case .left, .leftMirrored, .right, .rightMirrored:
            adjustedPicCenter = CGPoint(x: adjustedPicCenter.y, y: adjustedPicCenter.x)
            adjustedFrameSize = CGSize(width: scaledFrameSize.height, height: scaledFrameSize.width)
        @unknown default: break
        }
        
        let frameCenter = adjustedPicCenter - adjustedPanOffset
        let frameOrigin = frameCenter - (adjustedFrameSize / 2)
        let cropRect = CGRect(origin: frameOrigin, size: adjustedFrameSize)

        guard let croppedImage = cgImg.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedImage, scale: alteredOriginalImage.scale, orientation: alteredOriginalImage.imageOrientation)
    }
    
    func applyFiltersToTarget() {
        guard let originImage = originImage else { return }
        targetImage = applyFilters(input: originImage)
    }
    
    func applyFilters(input: UIImage) -> UIImage? {
        var ciImage = CIImage(image: input)

        // apply rotation
        ciImage = ciImage?.applyingFilter("CIAffineTransform",
                                          parameters: [kCIInputTransformKey: CGAffineTransform(rotationAngle: -rotatedAngle)])
        
        // apply selected filter
        if let selectedFilter = selectedFilter {
            selectedFilter.setValue(ciImage, forKey: kCIInputImageKey)
            ciImage = selectedFilter.outputImage ?? ciImage
        }
        
        // apply saturation brightness contrast
        let calSaturation = EditOption.saturation.calculatedValue(percent: saturationPercent)
        let calBrightness = EditOption.brightness.calculatedValue(percent: brightnessPercent)
        let calContrast = EditOption.contrast.calculatedValue(percent: contrastPercent)
        
        ciImage = ciImage?.applyingFilter("CIColorControls",
                               parameters: [kCIInputContrastKey: calContrast, // default: 1.0
                                          kCIInputSaturationKey: calSaturation, // default: 1.0
                                          kCIInputBrightnessKey: calBrightness]) // default: 0.0
        
        // apply temperature filter
        let calWarmth = EditOption.warmth.calculatedValue(percent: warmthPercent)
        ciImage = ciImage?.applyingFilter("CITemperatureAndTint", parameters: ["inputNeutral": CIVector(x: calWarmth, y: 0)])
        
        // apply Sharpness filter
        let calSharpen = EditOption.sharpen.calculatedValue(percent: sharpenPercent)
        ciImage = ciImage?.applyingFilter("CISharpenLuminance", parameters: [kCIInputSharpnessKey: calSharpen])
        
        // apply Vignette
        if vignettePercent != 0.0 {
            let calVignette = EditOption.vignette.calculatedValue(percent: vignettePercent)
            ciImage = ciImage?.vignetteEffect(center: input.size.center, radius: Float(input.size.width) * Float(calVignette))
        }
        
        // apply vibrance
        let calVibrance = EditOption.vibrance.calculatedValue(percent: vibrancePercent)
        ciImage = ciImage?.vibrance(amount: Float(calVibrance))
        
        // apply exposure
        let calExposure = EditOption.exposure.calculatedValue(percent: exposurePercent)
        ciImage = ciImage?.exposureAdjust(ev: Float(calExposure))
        
        // apply clarity
        let calClarity = EditOption.clarity.calculatedValue(percent: clarityPercent)
        ciImage = ciImage?.unsharpMask(radius: Float(calClarity))
        
        guard let outputImage = ciImage else { return nil }
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg, scale: input.scale, orientation: input.imageOrientation)
        }
        return nil
    }
    
    func applyPhotoEffects(input: UIImage, type: PhotoFilterTypes) -> UIImage? {
        guard let inputCIImage = CIImage(image: input) else {
            return nil
        }
        
        let outputCIImage: CIImage
        
        switch type {
        case .Chrome:
            outputCIImage = inputCIImage.photoEffectChrome()
        case .Fade:
            outputCIImage = inputCIImage.photoEffectFade()
        case .Instant:
            outputCIImage = inputCIImage.photoEffectInstant()
        case .Mono:
            outputCIImage = inputCIImage.photoEffectMono()
        case .Noir:
            outputCIImage = inputCIImage.photoEffectNoir()
        case .Process:
            outputCIImage = inputCIImage.photoEffectProcess()
        case .Tonal:
            outputCIImage = inputCIImage.photoEffectTonal()
        case .Transfer:
            outputCIImage = inputCIImage.photoEffectTransfer()
        }
        
        if let cgImage = CIContext().createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
    
    func applyPhotoPreviewEffects(input: UIImage) {
        for type in PhotoFilterTypes.allCases {
            let filteredImage = FilteredImage(image: applyPhotoEffects(input: input, type: type)!, name: type.rawValue)
            DispatchQueue.main.async {
                self.filteredImages.append(filteredImage)
            }
        }
        
    }
}
