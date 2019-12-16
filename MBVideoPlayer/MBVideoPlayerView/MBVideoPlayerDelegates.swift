//
//  MBVideoPlayerDelegates.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/9/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit
import AVKit

enum MBVideoPlayerState {
    case readyToPlay
    case playing
    case pause
    case playedToTheEnd
    case error
}

// 1- MBVideoPlayerView

protocol MBVideoPlayerViewDelegate: class {
    var playerStateDidChange: ((MBVideoPlayerState)->())? {get set}
    var playerTimeDidChange: ((TimeInterval, TimeInterval)->())? {get set}
    var playerOrientationDidChange: ((PlayerDimension) -> ())? {get set}
    var playerDidChangeSize: ((PlayerDimension) -> ())? {get set}
    var playerCellForItem: (()->(UICollectionViewCell))? {get set}
    var playerDidSelectItem: ((IndexPath)->())? {get set}
}

extension MBVideoPlayerViewDelegate {
    var playerStateDidChange: ((MBVideoPlayerState)->())? { get { return nil } set {  } }
    var playerTimeDidChange: ((TimeInterval, TimeInterval)->())? { get { nil } set { } }
    var playerOrientationDidChange: ((PlayerDimension) -> ())? { get { return nil } set { } }
    var playerDidChangeSize: ((PlayerDimension) -> ())? { get { return nil } set { } }
    var playerCellForItem: (()->(UICollectionViewCell))? { get { return nil } set { } }
    var playerDidSelectItem: ((IndexPath)->())? { get { return nil } set { } }
}

// 2- MBVideoPlayerControls

protocol MBVideoPlayerControlsDelegate: MBVideoPlayerViewDelegate where Self: UIView {
    var totalDuration: CMTime? { get }
    var currentTime: CMTime? { get }
    var mainContainerView: UIView? { get set }
    
    func loadVideo(_ url: URL)
    func seekToTime(_ seekTime: CMTime)
    func playPause(_ isActive: Bool)
}



