//
//  MBVideoPlayerDelegates.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/9/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit
import AVKit

/**
 enum which will represent different state of player
  - readyToPlay: when video is about to start play
  - playing: when video is playing
  - pause: when video is paused
  - playedToTheEnd: when video is about to finished
  - error: when there is error playing video
 */
public enum MBVideoPlayerState {
    case readyToPlay
    case playing
    case pause
    case playedToTheEnd
    case error
}

/** MBVideoPlayerControlsDelegate which can can listen to different events
    - playerStateDidChange: it monitors different state of the player like ready to play, playing, pause, playedto end, error.
    - playerTimeDidChange: it is called when video time is changed using forward or backward with total duration of video and new time.
    - playerOrientationDidChange: it is called when player orientation got changed.
    - playerDidChangeSize: it is called when player type is changed from embed to fullScreen to vice versa.
    - playerCellForItem: we can provide our custom playlist cell in this call back.
    - playerDidSelectItem: it is called when playerlist item is selected
*/
public protocol MBVideoPlayerControlsDelegate where Self: UIView {
    
    var playerStateDidChange: ((_ state: MBVideoPlayerState)->())? {get set}
    var playerTimeDidChange: ((_ newTime: TimeInterval, _ duration: TimeInterval)->())? {get set}
    var playerOrientationDidChange: ((_ dimension: PlayerDimension) -> ())? {get set}
    var playerDidChangeSize: ((PlayerDimension) -> ())? {get set}
    var playerCellForItem: ((UICollectionView, IndexPath)->(UICollectionViewCell))? {get set}
    var playerDidSelectItem: ((Int)->())? {get set}
    var didSelectOptions: ((PlayerItem) -> ())? { get set }
    
    var totalDuration: CMTime? { get }
    var currentTime: CMTime? { get }
    var fullScreenView: UIView? { get set }
    
    func didLoadVideo(_ url: URL)
    func seekToTime(_ seekTime: CMTime)
    func playPause(_ isActive: Bool)
}



