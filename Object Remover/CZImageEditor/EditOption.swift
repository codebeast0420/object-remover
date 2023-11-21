//
//  EditOption.swift
//  TestingForPhotoEditor
//
//  Created by Kaiyi Zhao on 8/6/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

enum EditOption: String, CaseIterable {
    case rotation = "Adjust"
    case brightness = "Brightness"
    case contrast = "Contrast"
    case saturation = "Saturation"
    case warmth = "Warmth"
    case sharpen = "Sharpen"
    
    case vignette = "Vignette"
    case vibrance = "Vibrance"
    case exposure = "Exposure"
    case clarity = "Clarity"
    
    var minValue: Double {
        switch self {
        case .rotation: return -90.0 * 100
        case .brightness: return -10
        case .contrast: return 50
        case .saturation: return -100
        case .warmth: return (6500 - 4500) * 100
        case .sharpen: return (0.4 - 1.0) * 100
            
        case .vignette: return 0
        case .vibrance: return -100
        case .exposure: return -100
        case .clarity: return -200
        }
    }
    
    var maxValue: Double {
        switch self {
        case .rotation: return 90.0 * 100
        case .brightness: return 10
        case .contrast: return 150
        case .saturation: return 300.0
        case .warmth: return (6500 + 4500) * 100
        case .sharpen: return (0.4 + 1.0) * 100
        case .vignette: return 50
        case .vibrance: return 100
        case .exposure: return 100
        case .clarity: return 200
        }
    }
    
    func calculatedValue(percent: Double) -> Double {
        var calvalue = (percent * (self.maxValue - self.minValue) + self.minValue)/100
        if self.rawValue == "Vignette"{
            calvalue = 1 - calvalue
            print("\(self.rawValue) / \(percent) / \(calvalue)")
        }
        
        return calvalue
    }
}

enum PhotoFilterTypes: String, CaseIterable {
    case Chrome = "Chrome"
    case Fade = "Fade"
    case Instant = "Instant"
    case Mono = "Mono"
    case Noir = "Noir"
    case Process = "Process"
    case Tonal = "Tonal"
    case Transfer = "Transfer"
}

