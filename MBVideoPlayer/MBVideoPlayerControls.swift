//
//  MBVideoOverlay.swift
//  MBVideoPlayer
//
//  Created by Muhammad Waqas on 07/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import UIKit
import AVKit

protocol MBVideoPlayerControlsDelegate: class {
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, cellForRowAtIndexPath: IndexPath) -> UICollectionViewCell?
    func mbOverlayView(_ overlayView: MBVideoPlayerControls, didSelectRowAtIndex: IndexPath)
}

class MBVideoPlayerControls: UIView {
    
    private var playButton: UIButton!
    private var backButton: UIButton!
    private var forwardButton: UIButton!
    private var resizeButton: UIButton!
    private var playerTimeLabel: UILabel!
    private var seekSlider: UISlider!
    private var activityView = UIActivityIndicatorView(style: .large)
    let videosStackView = UIStackView()
    private var cellId = "videoCellId"
    private var playerItems: [PlayerItem]?
    private var isShowOverlay: Bool = true

    private var isActive: Bool = false

    var canShowVideoList = true
    var canShowTime = true
    var canShowPlayPause = true
    var canShowTimeBar = true
    var canShowFullScreenBtn = true
    var canShowForwardBack = true

    var dimension: PlayerDimension = .embed
    var delegate: MBVideoPlayerControlsDelegate?
    weak var videoPlayerView: MBVideoPlayerView?
    
    var queuePlayer: AVQueuePlayer! {
        return videoPlayerView?.queuePlayer
    }

    private var topC: NSLayoutConstraint?
    private var bottomC: NSLayoutConstraint?
    private var rightC: NSLayoutConstraint?
    private var leftC: NSLayoutConstraint?

    lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - View Initializers

    override init(frame: CGRect) {
      super.init(frame: frame)
      addOverlay()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addOverlay()
    }
    
    private func addOverlay() {
        
        
        
    }
    func setPlayList(_ items: [PlayerItem], videoPlayerView: MBVideoPlayerView) {
        playerItems = items
        self.videoPlayerView = videoPlayerView
        collectionView.reloadData()
    }
    func createOverlayView() {
        
        // activity indicator
        activityView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityView)
        activityView.color = .white
        activityView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityView.startAnimating()
        
        if canShowPlayPause {
            addPlayPauseButton()
        }
        
        if canShowForwardBack {
            addForwardBackwardButton()
        }
        
        if canShowTime {
            addTimeLabel()
        }
        
        if canShowTimeBar {
            addTimeBarWith(playerTimeLabel)
        }
        
        if canShowFullScreenBtn {
            addResizeBtnWith(seekSlider)
        }
        
        if canShowVideoList {
            addPlayList()
        }

        
        
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.activityView.isHidden = true
                    } else {
                        self?.activityView.isHidden = false
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func changeSeekSlider(_ sender: UISlider) {
        guard let duration = videoPlayerView?.duration else { return }
        let seekTime = CMTime(seconds: Double(sender.value) * duration.asDouble, preferredTimescale: 100)
        self.videoPlayerView?.seekToTime(seekTime)
    }
    
    @objc func clickPlayButton(_ sender: UIButton) {
        playButton.setImage(UIImage(systemName: isActive ? "play.fill" : "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large)), for: .normal)
        isActive ? queuePlayer.pause() : queuePlayer.play()
        self.isActive = !self.isActive
        print("clicked -> \(isActive)")
    }
    
    @objc func clickBackButton(_ sender: UIButton) {
        let playerCurrentTime = CMTimeGetSeconds(queuePlayer.currentTime())
        var newTime = playerCurrentTime - (videoPlayerView?.seekDuration ?? 0)

        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        queuePlayer.seek(to: time2)
        playerTimeLabel.text = time2.description
        guard let duration = videoPlayerView?.duration else { return }
        seekSlider.value = time2.asFloat / duration.asFloat
    }
    
    @objc func clickForwardButton(_ sender: UIButton) {
        guard let duration  = queuePlayer.currentItem?.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(queuePlayer.currentTime())
        let newTime = playerCurrentTime + (videoPlayerView?.seekDuration ?? 0)

        if newTime < CMTimeGetSeconds(duration) {

            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            queuePlayer.seek(to: time2)
            
            playerTimeLabel.text = time2.description
            seekSlider.value = time2.asFloat / duration.asFloat
        }
    }
    
    @objc func resizeButtonTapped(_ sender:UIButton) {
        switch dimension {
        case .embed:
            dimension = .fullScreen
            resizeButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large)), for: .normal)
            if let frame = videoPlayerView?.mainContainerView?.bounds {
                videoPlayerView?.playerLayer.frame = frame
                videosStackView.isHidden = false
                if let view = videoPlayerView?.mainContainerView {
                   // videoPlayerView?.pinEdges(to: view)
                   leftC = videoPlayerView?.leadingAnchor.constraint(equalTo: view.leadingAnchor)
                   rightC = videoPlayerView?.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                   topC = videoPlayerView?.topAnchor.constraint(equalTo: view.topAnchor)
                   bottomC = videoPlayerView?.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    if let leftC = leftC, let rightC = rightC, let bottomC = bottomC, let topC = topC {
                        NSLayoutConstraint.activate([leftC, rightC, topC, bottomC])
                        layoutIfNeeded()
                    }
                }
            }
        case .fullScreen:
            dimension = .embed
            if let leftC = leftC, let rightC = rightC, let bottomC = bottomC, let topC = topC {
                NSLayoutConstraint.deactivate([leftC, rightC, topC, bottomC])
                layoutIfNeeded()
                resizeButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large)), for: .normal)
                videoPlayerView?.playerLayer.frame = bounds
                videosStackView.isHidden = true
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    private func addResizeBtnWith(_ slider: UISlider?) {
        // resize button
        let resizeButton = UIButton()
        resizeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resizeButton)
        resizeButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large)), for: .normal)
        resizeButton.addTarget(self, action: #selector(self.resizeButtonTapped), for: .touchUpInside)
        if let slider = slider {
            resizeButton.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 10).isActive = true
            resizeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            resizeButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor, constant: 0).isActive = true
        } else {
            resizeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            resizeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
        resizeButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        resizeButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        self.resizeButton = resizeButton
    }
    private func addTimeBarWith(_ timeLabel: UILabel?) {
          // seek slider
          
          let slider = UISlider()
          slider.translatesAutoresizingMaskIntoConstraints = false
          addSubview(slider)
        if let label = timeLabel {
            slider.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5).isActive = true
            slider.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0).isActive = true
        } else {
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
          slider.addTarget(
              self,
              action: #selector(self.changeSeekSlider(_:)),
              for: .valueChanged)
          seekSlider = slider
    }
    private func addTimeLabel() {
        // time label
        
        let label = UILabel()
        label.text = CMTime.zero.description
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.textColor = .blue
        label.textAlignment = .center
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        playerTimeLabel = label

    }
    private func addPlayPauseButton() {
        // play/pause button
        let playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 49).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large)), for: .normal)
        playButton.addTarget(
            self,
            action: #selector(self.clickPlayButton(_:)),
            for: .touchUpInside)
        self.playButton = playButton
    }
    private func addForwardBackwardButton() {
        // backward button
        let backwardButton = UIButton()
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backwardButton)
        backwardButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -20.0).isActive = true
        backwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backwardButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large)), for: .normal)
        backwardButton.addTarget(
            self,
            action: #selector(self.clickBackButton(_:)),
            for: .touchUpInside)
        self.backButton = backwardButton
        // forward button
        let forwardButton = UIButton()
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(forwardButton)
        forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 20.0).isActive = true
        forwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        forwardButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .heavy, scale: .large)), for: .normal)
        forwardButton.addTarget(
            self,
            action: #selector(self.clickForwardButton(_:)),
            for: .touchUpInside)
        self.forwardButton = forwardButton
    }
    private func addPlayList() {
        // videos stackview
        videosStackView.isHidden = true
        videosStackView.axis = .horizontal
        videosStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(videosStackView)
        videosStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        videosStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        videosStackView.bottomAnchor.constraint(equalTo: self.seekSlider.topAnchor, constant: -10.0).isActive = true
        videosStackView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        
        // collectionView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        videosStackView.addSubview(collectionView)
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.leadingAnchor.constraint(equalTo: videosStackView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: videosStackView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: videosStackView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: videosStackView.bottomAnchor).isActive = true
    }
}

// MARK: - UICollectionView Delegate & Datasource

extension MBVideoPlayerControls: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerItems?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = delegate?.mbOverlayView(self, cellForRowAtIndexPath: indexPath) {
            return cell
        } else {
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? VideoCollectionViewCell else {
               return UICollectionViewCell()
           }
          // cell.setData(playerItems?[indexPath.row])
           return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.mbOverlayView(self, didSelectRowAtIndex: indexPath)
       if let url = URL(string: playerItems?[indexPath.row].url ?? "") {
           //loadVideo(url)
       }
    }
}

class VideoCollectionViewCell: UICollectionViewCell {

    private let videoThumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10.0
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(videoThumbnail)
        videoThumbnail.pinEdges(to: self)
    }
    
}

