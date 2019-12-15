//
//  MBConfiguration.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/9/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation


struct MBConfiguration {
    
    var canShowVideoList = true
    var canShowTime = true
    var canShowPlayPause = true
    var canShowTimeBar = true
    var canShowFullScreenBtn = true
    var canShowForwardBack = true
    var canShowHeader = true
    var canShowHeaderTitle = true
    var canShowHeaderOption = true
    var dimension: PlayerDimension = .embed

    let seekDuration: Float64 = 15.0

    
}
