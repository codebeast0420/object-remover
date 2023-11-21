//
//  ImageEditorParameters.swift
//  TestPhotoEditor
//
//  Created by Kaiyi Zhao on 8/19/22.
//

import SwiftUI
import CoreImage

public struct ImageEditorParameters {
    let fullOriginalImage: UIImage?
    let attributes: Attributes
    
    public init(fullOriginalImage: UIImage? = nil, attributes: Attributes = .init()) {
        self.fullOriginalImage = fullOriginalImage
        self.attributes = attributes
    }
    
    public struct Attributes: Equatable {
        let appliedFilter: CIFilter?
        let steadyPanOffset: CGSize
        let steadyZoomScale: CGFloat
        let savedRotationPercent: Double
        let savedBrightnessPercent: Double
        let savedContrastPercent: Double
        let savedSaturationPercent: Double
        let savedSharpenPercent: Double
        let savedWarmthPercent: Double
        let savedvignettePercent: Double
        let savedvibrancePercent: Double
        let savedexposurePercent: Double
        let savedclarityPercent: Double
        
        public init(appliedFilter: CIFilter? = nil,
             steadyPanOffset: CGSize = .zero,
             steadyZoomScale: CGFloat = 1,
             savedRotationPercent: Double = 0.5,
             savedBrightnessPercent: Double = 0.5,
             savedContrastPercent: Double = 0.5,
             savedSaturationPercent: Double = 0.5,
             savedSharpenPercent: Double = 0.5,
             savedWarmthPercent: Double = 0.5,
             
             savedvignettePercent: Double = 0.0,
             savedvibrancePercent: Double = 0.5,
             savedexposurePercent: Double = 0.5,
             savedclarityPercent: Double = 0.5
            ) {
            self.appliedFilter = appliedFilter
            self.steadyPanOffset = steadyPanOffset
            self.steadyZoomScale = steadyZoomScale
            self.savedRotationPercent = savedRotationPercent
            self.savedBrightnessPercent = savedBrightnessPercent
            self.savedContrastPercent = savedContrastPercent
            self.savedSaturationPercent = savedSaturationPercent
            self.savedSharpenPercent = savedSharpenPercent
            self.savedWarmthPercent = savedWarmthPercent
            self.savedvignettePercent = savedvignettePercent
            self.savedvibrancePercent = savedvibrancePercent
            self.savedexposurePercent = savedexposurePercent
            self.savedclarityPercent = savedclarityPercent
        }
    }
}
