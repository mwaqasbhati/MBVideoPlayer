//
//  AVPlayerView.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 02/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import AVKit

public enum PlayerDimension {
    case embed
    case fullScreen
}


open class MBVideoPlayerView: UIView {
    
    // MARK: - Constants

    var playerStateDidChange: ((MBVideoPlayerState)->())? = nil
    var playerTimeDidChange: ((TimeInterval, TimeInterval)->())? = nil
    var playerOrientationDidChange: ((PlayerDimension) -> ())? = nil
    var playerDidChangeSize: ((PlayerDimension) -> ())? = nil
    var playerCellForItem: (()->(UICollectionViewCell))? = nil
    var playerDidSelectItem: ((IndexPath)->())? = nil
    
    // MARK: - Instance Variables

    private var isShowOverlay: Bool = true
    private var task: DispatchWorkItem? = nil
    private var queuePlayer: AVQueuePlayer!
    private var playerLayer: AVPlayerLayer!

    let overlayView = MBVideoPlayerControls()
    var delegate: MBVideoPlayerViewDelegate?
    var configuration: MBConfiguration = MainConfiguration()
    var theme: MBTheme = MainTheme()
    var mainContainerView: UIView?
            
    var totalDuration: CMTime? {
        return self.queuePlayer.currentItem?.asset.duration
    }
    
    var currentTime: CMTime? {
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
    required public init(configuration: MBConfiguration?, theme: MBTheme?) {
        super.init(frame: .zero)
        if let theme = theme {
            self.theme = theme
        }
        if let configuration = configuration {
            self.configuration = configuration
        }
        setupPlayer()
    }
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupPlayer()
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
        
    }
    // MARK: - Helper Methods

    func setPlayListItemsWith(delegate: MBVideoPlayerViewDelegate, currentItem: PlayerItem, items: [PlayerItem], fullView: UIView? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        playerLayer.frame = self.bounds
        mainContainerView = fullView
        self.delegate = delegate
        addObservers()
        if let url = URL(string: currentItem.url) {
            loadVideo(url)
        }
        overlayView.setPlayListWith(currentItem: currentItem, items: items)
    }
    private func setupPlayer(_ showOverlay: Bool = true) {
        
        createPlayerView()
        
        isShowOverlay = showOverlay
        if showOverlay {
            overlayView.createOverlayViewWith(configuration: configuration, theme: theme)
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(overlayView)
            overlayView.delegate = self
            overlayView.backgroundColor = .clear
            overlayView.pinEdges(to: self)
        }
        
        queuePlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 100),
            queue: DispatchQueue.main,
            using: { [weak self] (cmtime) in
                print(cmtime)
                self?.overlayView.videoDidChange(cmtime)
        })
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        bringSubviewToFront(overlayView)
        backgroundView.pinEdges(to: self)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    @objc func onOrientationChanged() {
        if let didChangeOrientation = playerOrientationDidChange {
            didChangeOrientation(configuration.dimension)
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if isShowOverlay {
            overlayView.isHidden = true
            backgroundView.isHidden = true
            task?.cancel()
        } else {
            overlayView.isHidden = false
            backgroundView.isHidden = false
            task = DispatchWorkItem {
                self.overlayView.isHidden = true
                self.backgroundView.isHidden = true
                self.isShowOverlay = !self.isShowOverlay
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10), execute: task!)
        }
        isShowOverlay = !isShowOverlay
    }
    
    private func createPlayerView() {
        queuePlayer = AVQueuePlayer()
        queuePlayer.addObserver(overlayView, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspect
        self.layer.addSublayer(playerLayer)
    }
    
}

extension MBVideoPlayerView: MBVideoPlayerControlsDelegate {
    
    func addObservers() {
     //   playerStateDidChange = delegate?.playerStateDidChange
     //   playerTimeDidChange = delegate?.playerTimeDidChange
    //    playerOrientationDidChange = delegate?.playerOrientationDidChange
     //   playerDidChangeSize = delegate?.playerDidChangeSize
     //   playerCellForItem = delegate?.playerCellForItem
     //   playerDidSelectItem = delegate?.playerDidSelectItem
    }
    func loadVideo(_ url: URL) {
        queuePlayer.removeAllItems()
        let playerItem = AVPlayerItem.init(url: url)
        queuePlayer.insert(playerItem, after: nil)
        overlayView.videoDidStart()
        playerStateDidChange!(.readyToPlay)
    }
    
    func seekToTime(_ seekTime: CMTime) {
        print(seekTime)
        self.queuePlayer.currentItem?.seek(to: seekTime, completionHandler: nil)
    }
    func playPause(_ isActive: Bool) {
        isActive ? queuePlayer.play() : queuePlayer.pause()
    }
}

extension MBVideoPlayerView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.classForCoder == UIButton.classForCoder() { return false }
        return true
    }
}

extension UIView {
    func pinEdges(to other: UIView) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}



