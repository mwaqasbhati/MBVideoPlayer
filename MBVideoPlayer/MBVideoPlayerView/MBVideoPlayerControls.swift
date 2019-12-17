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

    lazy private var playButton: UIButton! = {
       let playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(self.clickPlayButton(_:)), for: .touchUpInside)
        return playButton
    }()
    
    lazy private var backButton: UIButton! = {
        let backwardButton = UIButton()
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        backwardButton.addTarget(self, action: #selector(self.clickBackButton(_:)), for: .touchUpInside)
        return backwardButton
    }()
    
    lazy private var forwardButton: UIButton! = {
       let forwardButton = UIButton()
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.addTarget(self, action: #selector(self.clickForwardButton(_:)), for: .touchUpInside)
        return forwardButton
    }()
    
    lazy private var resizeButton: UIButton = {
        let resizeButton = UIButton()
        resizeButton.translatesAutoresizingMaskIntoConstraints = false
        resizeButton.addTarget(self, action: #selector(self.resizeButtonTapped), for: .touchUpInside)
        return resizeButton
    }()
    
    lazy private var playerTimeLabel: UILabel = {
        let label = UILabel()
        label.text = CMTime.zero.description
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    lazy private var fullTimeLabel: UILabel = {
       let timeLabel = UILabel()
        timeLabel.text = delegate?.totalDuration?.description ?? CMTime.zero.description
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .center
        return timeLabel
    }()
    
    lazy private var seekSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(self.changeSeekSlider(_:)), for: .valueChanged)
        return slider
    }()
    
    lazy private var activityView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        return activity
    }()
    
    lazy private var playListStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isHidden = true
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy private var bottomControlsStackView: UIStackView  = {
       let stackView = UIStackView()
       stackView.axis = .horizontal
       stackView.translatesAutoresizingMaskIntoConstraints = false
       return stackView
    }()
    
    private lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var playerItems: [PlayerItem]?
    
    private var currentItem: PlayerItem?
    
    private var isActive: Bool = false

    var delegate: MBVideoPlayerControlsDelegate?
    
    var videoPlayerHeader: MBVideoPlayerHeaderView?
    
    var configuration = MainConfiguration()
    
    var theme = MainTheme()
    
    private var topC: NSLayoutConstraint?
    private var bottomC: NSLayoutConstraint?
    private var rightC: NSLayoutConstraint?
    private var leftC: NSLayoutConstraint?

    private var cellId = "videoCellId"
    
    // MARK: - View Initializers

    override init(frame: CGRect) {
      super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setPlayList(currentItem: PlayerItem, items: [PlayerItem]) {
        
        if let player = delegate?.playerDidRegisterCell {
            let attributes = player()
            collectionView.register(attributes.cell.self, forCellWithReuseIdentifier: attributes.cellIdentifier)
        } else {
            collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        }
        
        playerItems = items
        self.currentItem = currentItem
        collectionView.reloadData()
        videoPlayerHeader?.setTitle(currentItem.title)
        
    }
    
    func createOverlayViewWith(configuration: MBConfiguration, theme: MBTheme) {
        
        // activity indicator
        addSubview(activityView)
        activityView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(bottomControlsStackView)
        bottomControlsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        bottomControlsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        bottomControlsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true

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
            addTimeBar()
        }
        
        if configuration.canShowTime {
            addTotalTimeLabel()
        }
        
        if configuration.canShowFullScreenBtn {
            addResizeBtn()
        }
        
        if configuration.canShowVideoList {
            addPlayList()
        }

        if configuration.canShowHeader {
            videoPlayerHeader = MBVideoPlayerHeaderView(configuration: configuration, theme: theme, delegate: delegate)
            addSubview(videoPlayerHeader!)
            videoPlayerHeader!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
            videoPlayerHeader!.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            videoPlayerHeader!.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        }
        
        applyTheme(theme)
    }
    
    private func applyTheme(_ theme: MBTheme) {
        playButton.tintColor = theme.buttonTintColor
        forwardButton.tintColor = theme.buttonTintColor
        backButton.tintColor = theme.buttonTintColor
        resizeButton.tintColor = theme.buttonTintColor
        fullTimeLabel.textColor = theme.timeLabelTextColor
        playerTimeLabel.textColor = theme.timeLabelTextColor
        seekSlider.tintColor = theme.sliderTintColor
        seekSlider.thumbTintColor = theme.sliderThumbColor
        activityView.color = theme.activityViewColor
        collectionView.backgroundColor = theme.playListItemsBackgroundColor
        resizeButton.setImage(theme.resizeButtonImage, for: .normal)
        playButton.setImage((isActive ? theme.pauseButtonImage : theme.playButtonImage), for: .normal)
        forwardButton.setImage(theme.forwardButtonImage, for: .normal)
        backButton.setImage(theme.backButtonImage, for: .normal)
    }
    
    func videoDidStart() {
        playerTimeLabel.text = CMTime.zero.description
        seekSlider.value = 0.0
        fullTimeLabel.text = delegate?.totalDuration?.description ?? CMTime.zero.description
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
                    guard let `self` = self else { return }
                    if newStatus == .playing || newStatus == .paused {
                        if let player = self.delegate?.playerStateDidChange {
                            player((self.isActive ? MBVideoPlayerState.pause : MBVideoPlayerState.playing))
                        }
                        self.activityView.isHidden = true
                    } else {
                        self.activityView.isHidden = false
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func changeSeekSlider(_ sender: UISlider) {
        guard let totalDuration = delegate?.totalDuration else { return }
        let seekTime = CMTime(seconds: Double(sender.value) * totalDuration.asDouble, preferredTimescale: 100)
        playerTimeLabel.text = seekTime.description
        delegate?.seekToTime(seekTime)
        if let player = delegate?.playerTimeDidChange {
            player(seekTime.asDouble, totalDuration.asDouble)
        }
    }
    
    @objc func clickPlayButton(_ sender: UIButton) {
        isActive = !isActive
        playButton.setImage(Controls.playpause(isActive).image, for: .normal)
        delegate?.playPause(isActive)
        print("clicked -> \(isActive)")
    }
    
    @objc func clickBackButton(_ sender: UIButton) {
        guard let totalDuration = delegate?.totalDuration, let current = delegate?.currentTime, isActive else { return }
        let playerCurrentTime = CMTimeGetSeconds(current)
        var newTime = playerCurrentTime - configuration.seekDuration

        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        delegate?.seekToTime(time2)
        playerTimeLabel.text = time2.description
        seekSlider.value = time2.asFloat / totalDuration.asFloat
        if let player = delegate?.playerTimeDidChange {
            player(time2.asDouble, totalDuration.asDouble)
        }
    }
    
    @objc func clickForwardButton(_ sender: UIButton) {
        guard let totalDuration  = delegate?.totalDuration, let current = delegate?.currentTime, isActive else { return }
        let playerCurrentTime = CMTimeGetSeconds(current)
        let newTime = playerCurrentTime + configuration.seekDuration

        if newTime < CMTimeGetSeconds(totalDuration) {
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            delegate?.seekToTime(time2)
            playerTimeLabel.text = time2.description
            seekSlider.value = time2.asFloat / totalDuration.asFloat
            if let player = delegate?.playerTimeDidChange {
                player(time2.asDouble, totalDuration.asDouble)
            }
        }
    }
    
    @objc func resizeButtonTapped(_ sender:UIButton) {
        if let player = delegate?.playerDidChangeSize {
            player(configuration.dimension)
        }

        switch configuration.dimension {
        case .embed:
            if let _ = delegate?.fullScreenView?.bounds {
                playListStackView.isHidden = false
                if let view = delegate?.fullScreenView {
                   leftC = delegate?.leadingAnchor.constraint(equalTo: view.leadingAnchor)
                   rightC = delegate?.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                   topC = delegate?.topAnchor.constraint(equalTo: view.topAnchor)
                   bottomC = delegate?.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
                playListStackView.isHidden = true
            }
            configuration.dimension = .embed
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func addResizeBtn() {
        // resize button
        bottomControlsStackView.addArrangedSubview(resizeButton)
        resizeButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        resizeButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
    private func addTimeBar() {
          // seek slider
          bottomControlsStackView.addArrangedSubview(seekSlider)
          seekSlider.centerYAnchor.constraint(equalTo: bottomControlsStackView.centerYAnchor, constant: 0).isActive = true
    }
    
    private func addTimeLabel() {
        // time label
        bottomControlsStackView.addArrangedSubview(playerTimeLabel)
        playerTimeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        playerTimeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func addTotalTimeLabel() {
        // total time label
        bottomControlsStackView.addArrangedSubview(fullTimeLabel)
        fullTimeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fullTimeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func addPlayPauseButton() {
        // play/pause button
        addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func addForwardBackwardButton() {
        // backward button
        addSubview(backButton)
        backButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -25.0).isActive = true
        backButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        // forward button
        
        addSubview(forwardButton)
        forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 25.0).isActive = true
        forwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
    }
    
    private func addPlayList() {
        // videos stackview
        addSubview(playListStackView)
        playListStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        playListStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        playListStackView.bottomAnchor.constraint(equalTo: self.seekSlider.topAnchor, constant: -10.0).isActive = true
        playListStackView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        
        // collectionView
        playListStackView.addSubview(collectionView)
        collectionView.pinEdges(to: playListStackView)
    }
}

// MARK: - UICollectionView Delegate & Datasource

extension MBVideoPlayerControls: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = delegate?.playerCellForItem {
            return cell(collectionView, indexPath)
        } else {
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? VideoCollectionViewCell else {
               return UICollectionViewCell()
           }
            cell.setData(playerItems?[indexPath.row], theme: theme)
           return cell
        }
    }
    
}

extension MBVideoPlayerControls: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let player = delegate?.playerDidSelectItem {
            player(indexPath)
        }
        if let url = URL(string: playerItems?[indexPath.row].url ?? ""), let title = playerItems?[indexPath.row].title {
            delegate?.didLoadVideo(url)
            videoPlayerHeader?.setTitle(title)
        }
    }
    
}


