//
//  CMTime+extension.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/9/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import AVKit

/// CMTIme: it converts CMTime to double, float and format the CMTime object to representable on the UI.

extension CMTime {
    var asDouble: Double {
        get {
            return Double(self.value) / Double(self.timescale)
        }
    }
    var asFloat: Float {
        get {
            return Float(self.value) / Float(self.timescale)
        }
    }
}

extension CMTime: CustomStringConvertible {
    public var description: String {
        get {
            let seconds = Int(round(self.asDouble))
            return String(format: "%02d:%02d", seconds / 60, seconds % 60)
        }
    }
}

/// Controls: This enum keeps images of the constols according to their state.

enum Controls {
    
    case playpause(Bool)
    case forward
    case back
    case slider
    case resize(PlayerDimension)
    case options
    
    public var image: UIImage? {
        switch self {
        case .playpause(let isActive):
            return UIImage(systemName: isActive ? "pause.fill" : "play.fill" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large))
        case .resize(let dimension):
            switch dimension {
            case .embed:
                return UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large))
            case .fullScreen:
                return UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large))
            }
        case .back:
            return UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .heavy, scale: .medium))
        case .forward:
            return UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .heavy, scale: .medium))
        case .options:
            return UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .heavy, scale: .medium))
        default:
            return nil
            
            
        }
    }
}
