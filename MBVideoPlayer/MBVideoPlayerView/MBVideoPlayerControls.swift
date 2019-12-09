//
//  MBVideoOverlay.swift
//  MBVideoPlayer
//
//  Created by Muhammad Waqas on 07/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit
import AVKit


class MBVideoPlayerControls: UIView {
    
    // MARK: - Constants

    // MARK: - Instance Variables

    private var playButton: UIButton!
    private var backButton: UIButton!
    private var forwardButton: UIButton!
    private var resizeButton: UIButton!
    private var playerTimeLabel: UILabel!
    private var seekSlider: UISlider!
    private var activityView = UIActivityIndicatorView(style: .large)
    private let videosStackView = UIStackView()
    private var playerItems: [PlayerItem]?

    private var isActive: Bool = false

    var delegate: MBVideoPlayerControlsDelegate?
    weak var videoPlayerView: MBVideoPlayerView?
    var configuration = MBConfiguration()

    private var topC: NSLayoutConstraint?
    private var bottomC: NSLayoutConstraint?
    private var rightC: NSLayoutConstraint?
    private var leftC: NSLayoutConstraint?

    private var cellId = "videoCellId"

    private lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - View Initializers

    override init(frame: CGRect) {
      super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setPlayList(_ items: [PlayerItem], videoPlayerView: MBVideoPlayerView) {
        playerItems = items
        self.videoPlayerView = videoPlayerView
        collectionView.reloadData()
    }
    func createOverlayView() {
        
        // activity indicator
        activityView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityView)
        activityView.color = .white
        activityView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityView.startAnimating()
        
        if configuration.canShowPlayPause {
            addPlayPauseButton()
        }
        
        if configuration.canShowForwardBack {
            addForwardBackwardButton()
        }
        
        if configuration.canShowTime {
            addTimeLabel()
        }
        
        if configuration.canShowTimeBar {
            addTimeBarWith(playerTimeLabel)
        }
        
        if configuration.canShowFullScreenBtn {
            addResizeBtnWith(seekSlider)
        }
        
        if configuration.canShowVideoList {
            addPlayList()
        }

        
        
    }
    func videoDidStart() {
        playerTimeLabel.text = CMTime.zero.description
        seekSlider.value = 0.0
    }
    func videoDidChange(_ time: CMTime) {
        playerTimeLabel.text = time.description
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
        guard let totalDuration = videoPlayerView?.totalDuration else { return }
        let seekTime = CMTime(seconds: Double(sender.value) * totalDuration.asDouble, preferredTimescale: 100)
        playerTimeLabel.text = seekTime.description
        self.videoPlayerView?.seekToTime(seekTime)
    }
    
    @objc func clickPlayButton(_ sender: UIButton) {
        playButton.setImage(Controls.playpause(isActive).image, for: .normal)
        videoPlayerView?.playPause(isActive)
        isActive = !isActive
        print("clicked -> \(isActive)")
    }
    
    @objc func clickBackButton(_ sender: UIButton) {
        guard let totalDuration = videoPlayerView?.totalDuration, let current = videoPlayerView?.currentTime else { return }
        let playerCurrentTime = CMTimeGetSeconds(current)
        var newTime = playerCurrentTime - configuration.seekDuration

        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        videoPlayerView?.seekToTime(time2)
        playerTimeLabel.text = time2.description
        seekSlider.value = time2.asFloat / totalDuration.asFloat
    }
    
    @objc func clickForwardButton(_ sender: UIButton) {
        guard let totalDuration  = videoPlayerView?.totalDuration, let current = videoPlayerView?.currentTime else { return }
        let playerCurrentTime = CMTimeGetSeconds(current)
        let newTime = playerCurrentTime + configuration.seekDuration

        if newTime < CMTimeGetSeconds(totalDuration) {
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            videoPlayerView?.seekToTime(time2)
            playerTimeLabel.text = time2.description
            seekSlider.value = time2.asFloat / totalDuration.asFloat
        }
    }
    
    @objc func resizeButtonTapped(_ sender:UIButton) {
        delegate?.mbOverlayView(self, resizeAction: configuration.dimension)

        switch configuration.dimension {
        case .embed:
            if let _ = videoPlayerView?.mainContainerView?.bounds {
                delegate?.mbOverlayView(self, resizeAction: configuration.dimension)
                videosStackView.isHidden = false
                if let view = videoPlayerView?.mainContainerView {
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
            resizeButton.setImage(Controls.resize(configuration.dimension).image, for: .normal)
            configuration.dimension = .fullScreen
        case .fullScreen:
            if let leftC = leftC, let rightC = rightC, let bottomC = bottomC, let topC = topC {
                NSLayoutConstraint.deactivate([leftC, rightC, topC, bottomC])
                layoutIfNeeded()
                resizeButton.setImage(Controls.resize(configuration.dimension).image, for: .normal)
                videosStackView.isHidden = true
            }
            configuration.dimension = .embed
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
        resizeButton.setImage(Controls.resize(configuration.dimension).image, for: .normal)
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
        playButton.setImage(Controls.playpause(isActive).image, for: .normal)
        playButton.addTarget(self, action: #selector(self.clickPlayButton(_:)), for: .touchUpInside)
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
        backwardButton.setImage(Controls.back.image, for: .normal)
        backwardButton.addTarget(self, action: #selector(self.clickBackButton(_:)), for: .touchUpInside)
        self.backButton = backwardButton
        // forward button
        let forwardButton = UIButton()
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(forwardButton)
        forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 20.0).isActive = true
        forwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        forwardButton.setImage(Controls.forward.image, for: .normal)
        forwardButton.addTarget(self, action: #selector(self.clickForwardButton(_:)), for: .touchUpInside)
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
        delegate?.mbOverlayView(self, didSelectRowAtIndexPath: indexPath)
        if let url = URL(string: playerItems?[indexPath.row].url ?? "") {
          videoPlayerView?.loadVideo(url)
        }
    }
}



