//
//  MBVideoPlayerDelegates.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/9/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

enum MBVideoPlayerState {
    case readyToPlay
    case playing
    case pause
    case playedToTheEnd
    case error
}

// 1- MBVideoPlayerView

protocol MBVideoPlayerViewDelegate: class {
    func mbPlayerView(_ playerView: MBVideoPlayerView, playerStateDidChange: MBVideoPlayerState)
    func mbPlayerView(_ playerView: MBVideoPlayerView, playerTimeDidChange newTime: TimeInterval, totalDuration: TimeInterval)
    func mbPlayerView(_ playerView: MBVideoPlayerView, cellForRowAtIndexPath indexPath: IndexPath) -> UICollectionViewCell?
    func mbPlayerView(_ playerView: MBVideoPlayerView, didSelectRowAtIndexPath indexPath: IndexPath)
    func mbPlayerView(_ playerView: MBVideoPlayerView, resizeAction dimension: PlayerDimension)
    func mbPlayerView(_ playerView: MBVideoPlayerView, orientationDidChange: PlayerDimension)
}

extension MBVideoPlayerViewDelegate {
    func mbPlayerView(_ playerView: MBVideoPlayerView, cellForRowAtIndexPath indexPath: IndexPath) -> UICollectionViewCell? {
        return nil
    }
    func mbPlayerView(_ playerView: MBVideoPlayerView, playerStateDidChange: MBVideoPlayerState) { }
    func mbPlayerView(_ playerView: MBVideoPlayerView, playerTimeDidChange newTime: TimeInterval, totalDuration: TimeInterval) { }
    func mbPlayerView(_ playerView: MBVideoPlayerView, didSelectRowAtIndexPath indexPath: IndexPath) { }
    func mbPlayerViewReadyToPlayVideo(_ playerView: MBVideoPlayerView) {}
    func mbPlayerViewDidReachToEnd(_ playerView: MBVideoPlayerView) {}
    func mbPlayerView(_ playerView: MBVideoPlayerView, orientationDidChange: PlayerDimension) {}
}

// 2- MBVideoPlayerControls

protocol MBVideoPlayerControlsDelegate: class {
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, cellForRowAtIndexPath indexPath: IndexPath) -> UICollectionViewCell?
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, didSelectRowAtIndexPath indexPath: IndexPath)
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, resizeAction dimension: PlayerDimension)
}


