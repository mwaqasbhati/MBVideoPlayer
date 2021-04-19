//
//  AVPlayerView.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 02/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import AVKit

/**
enum to check player type
   - embed: used within the view as a small player
   - fullScreen: used as a full screen player
*/
public enum PlayerDimension {
    
    case embed
    case fullScreen
}

open class MBVideoPlayerView: UIView {
    
    // MARK: - Constants

    public var playerStateDidChange: ((MBVideoPlayerState)->())? = nil
    
    public var playerTimeDidChange: ((TimeInterval, TimeInterval)->())? = nil
    
    public var playerOrientationDidChange: ((PlayerDimension) -> ())? = nil
    
    public var playerDidChangeSize: ((PlayerDimension) -> ())? = nil
        
    public var playerCellForItem: ((UICollectionView, IndexPath)->(UICollectionViewCell))? = nil
    
    public var playerDidSelectItem: ((Int)->())? = nil
    
    public var didSelectOptions: ((PlayerItem) -> ())? = nil
    
    // MARK: - Instance Variables
    
    private var task: DispatchWorkItem? = nil
    
    private var queuePlayer: AVQueuePlayer!
    
    private var playerLayer: AVPlayerLayer?

    let overlayView = MBVideoPlayerControls()
    
    var configuration: MBConfiguration = MainConfiguration()
    
    var theme: MBTheme = MainTheme()
    
    public var fullScreenView: UIView? = nil
            
    public var totalDuration: CMTime? {
        return self.queuePlayer.currentItem?.asset.duration
    }
    
    public var currentTime: CMTime? {
        return self.queuePlayer.currentTime()
    }
    
    private lazy var backgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.6
        view.isOpaque = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - View Initializers
    
    required public init(configuration: MBConfiguration?, theme: MBTheme?, header: UIView?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        if let theme = theme {
            self.theme = theme
        }
        if let configuration = configuration {
            self.configuration = configuration
        }
        setupPlayer(header)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupPlayer(nil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer(nil)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
        
    }
    
    // MARK: - Helper Methods
    
    func didRegisterPlayerItemCell(_ identifier: String, collectioViewCell cell: UICollectionViewCell.Type) {
        overlayView.didRegisterPlayerItemCell(identifier, collectioViewCell: cell)
    }
    
    public func setPlayList(currentItem: PlayerItem, items: [PlayerItem], fullScreenView: UIView? = nil) {
        
        //playerLayer?.frame = self.bounds
        
        self.fullScreenView = fullScreenView
        
        if let url = URL(string: currentItem.url) {
            didLoadVideo(url)
        }
        
        overlayView.setPlayList(currentItem: currentItem, items: items)
    }
    
    private func setupPlayer(_ header: UIView?) {
        
        // setup avQueuePlayer
        
        createPlayer()
        
        // setup overlay
        
        createOverlay(header)
                
        // background view as a dim view having alphs 0.3
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        bringSubviewToFront(overlayView)
        backgroundView.pinEdges(to: self)

        /// single tap with which we show and hide overlay view
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        addGestureRecognizer(tap)

        // orientation change observer
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    /// this is called when device orientation got changed
    
    @objc func onOrientationChanged() {
        if let didChangeOrientation = playerOrientationDidChange {
            didChangeOrientation(configuration.dimension)
        }
    }
    
    /// this controls tap on player and show/hide overlay view
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if configuration.isShowOverlay {
            overlayView.isHidden = true
            backgroundView.isHidden = true
            task?.cancel()
        } else {
            overlayView.isHidden = false
            backgroundView.isHidden = false
            task = DispatchWorkItem {
                self.overlayView.isHidden = true
                self.backgroundView.isHidden = true
                self.configuration.isShowOverlay = !self.configuration.isShowOverlay
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10), execute: task!)
        }
        configuration.isShowOverlay = !configuration.isShowOverlay
        
    }
    
    /// this creates AVQueuePlayer
    
    private func createPlayer() {
        
        queuePlayer = AVQueuePlayer()
        queuePlayer.addObserver(overlayView, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.backgroundColor = UIColor.black.cgColor
        playerLayer?.videoGravity = .resizeAspect
        self.layer.addSublayer(playerLayer!)
        queuePlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 100),
            queue: DispatchQueue.main,
            using: { [weak self] (cmtime) in
                print(cmtime)
                self?.overlayView.videoDidChange(cmtime)
        })
        
    }
    
    /// this create overlay view on top of player with custom controls
    
    private func createOverlay(_ header: UIView?) {
        
        guard configuration.isShowOverlay else { return }
        overlayView.delegate = self
        overlayView.createOverlayViewWith(configuration: configuration, theme: theme, header: header)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        overlayView.backgroundColor = .clear
        overlayView.pinEdges(to: self)
        
    }
    
    public func toggleScreen() {
        overlayView.resizeButtonTapped(UIButton())
    }
    
}

// MARK: MBVideoPlayerControlsDelegate

extension MBVideoPlayerView: MBVideoPlayerControlsDelegate {
    
    public func didLoadVideo(_ url: URL) {
        
        queuePlayer.removeAllItems()
        
        let playerItem = AVPlayerItem.init(url: url)
        queuePlayer.insert(playerItem, after: nil)
        overlayView.videoDidStart()
        
        if let player = playerStateDidChange {
            player(.readyToPlay)
        }
    }
    
    public func seekToTime(_ seekTime: CMTime) {
        print(seekTime)
        self.queuePlayer.currentItem?.seek(to: seekTime, completionHandler: nil)
    }
    
    public func playPause(_ isActive: Bool) {
        isActive ? queuePlayer.play() : queuePlayer.pause()
    }
}

// MARK: MBVideoPlayerControlsDelegate

extension MBVideoPlayerView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.classForCoder == UIButton.classForCoder() { return false }
        return true
    }
}

// MARK: MBVideoPlayerControlsDelegate

extension UIView {
    public func pinEdges(to other: UIView) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}



