//
//  MBVideoPlayerDelegates.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/9/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

// 1- MBVideoPlayerView

protocol MBVideoPlayerViewDelegate: class {
    func mbPlayerViewReadyToPlayVideo(_ playerView: MBVideoPlayerView)
    func mbPlayerViewDidReachToEnd(_ playerView: MBVideoPlayerView)
    func mbPlayerView(_ playerView: MBVideoPlayerView, cellForRowAtIndexPath: IndexPath) -> UICollectionViewCell?
    func mbPlayerView(_ playerView: MBVideoPlayerView, didSelectRowAtIndex: IndexPath)
    func mbPlayerView(_ playerView: MBVideoPlayerView, resizeAction dimension: PlayerDimension)
}

extension MBVideoPlayerViewDelegate {
    func mbPlayerView(_ playerView: MBVideoPlayerView, cellForRowAtIndexPath: IndexPath) -> UICollectionViewCell? {
        return nil
    }
    func mbPlayerView(_ playerView: MBVideoPlayerView, didSelectRowAtIndex: IndexPath) { }
    func mbPlayerViewReadyToPlayVideo(_ playerView: MBVideoPlayerView) {}
    func mbPlayerViewDidReachToEnd(_ playerView: MBVideoPlayerView) {}
}

// 2- MBVideoPlayerControls

protocol MBVideoPlayerControlsDelegate: class {
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, cellForRowAtIndexPath: IndexPath) -> UICollectionViewCell?
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, didSelectRowAtIndex: IndexPath)
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, resizeAction dimension: PlayerDimension)
}


