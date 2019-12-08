//
//  AVPlayerView.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 02/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import AVKit

struct PlayerItem {
    let url: String
    let thumbnail: String
}

enum PlayerDimension {
    case embed
    case fullScreen
}

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


class MBVideoPlayerView: UIView {
    
    // MARK: - Constants

    // MARK: - Instance Variables

    var playerLayer: AVPlayerLayer!
    private var isShowOverlay: Bool = true
    private var isFullScreen: Bool = false
    private var dimension: PlayerDimension = .embed
    var mainContainerView: UIView?
    private var heightConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var task: DispatchWorkItem? = nil

    let overlayView = MBVideoPlayerControls()
    var delegate: MBVideoPlayerViewDelegate?
    var queuePlayer: AVQueuePlayer!
    
    let seekDuration: Float64 = 15.0
    
    
    var duration: CMTime? {
        return self.queuePlayer.currentItem?.asset.duration
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

    override init(frame: CGRect) {
      super.init(frame: frame)
      setupPlayer()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }
    
    // MARK: - Helper Methods

    func setPlayList(_ initilURL: URL, items: [PlayerItem], fullView: UIView? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
     //   heightConstraint = heightAnchor.constraint(equalToConstant: 400.0)
     //   heightConstraint?.isActive = true
     //   if let top = fullView?.safeAreaLayoutGuide.topAnchor {
     //       topConstraint = superview?.topAnchor.constraint(equalTo: top, constant: 55.0)
     //       topConstraint?.isActive = true
     //   }
     //   layoutIfNeeded()
        playerLayer.frame = self.bounds
        mainContainerView = fullView
        loadVideo(initilURL)
        overlayView.setPlayList(items, videoPlayerView: self)
    }
    private func setupPlayer() {
        
        createPlayerView()
        overlayView.createOverlayView()

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        overlayView.backgroundColor = .clear
        overlayView.pinEdges(to: self)
        
        queuePlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 100),
            queue: DispatchQueue.main,
            using: { [weak self] (cmtime) in
                print(cmtime)
              //  self?.playerTimeLabel.text = cmtime.description
        })
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        bringSubviewToFront(overlayView)
        backgroundView.pinEdges(to: self)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.addGestureRecognizer(tap)

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
    
    private func loadVideo(_ url: URL) {
        queuePlayer.removeAllItems()
        let playerItem = AVPlayerItem.init(url: url)
        queuePlayer.insert(playerItem, after: nil)
      //  playerTimeLabel.text = CMTime.zero.description
      //  seekSlider.value = 0.0
    }
    
    func seekToTime(_ seekTime: CMTime) {
        print(seekTime)
        self.queuePlayer.currentItem?.seek(to: seekTime, completionHandler: nil)
      //  self.playerTimeLabel.text = seekTime.description
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

extension MBVideoPlayerView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
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

extension UIButton {
    
    func setBackgroundImage(name: String) {
        UIGraphicsBeginImageContext(frame.size)
        UIImage(named: name)?.draw(in: bounds)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        backgroundColor = UIColor(patternImage: image)
    }
}
