//
//  MBTheme.swift
//  MBVideoPlayer
//
//  Created by Muhammad Waqas on 15/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

/// MBTheme: it controls player componenets fonts, colors and images

public protocol MBTheme {
    var buttonTintColor: UIColor { get }
    var headerBackgroundColor: UIColor { get }
    var headerBackgroundOpacity: Float { get }
    var playListCurrentItemTextColor: UIColor { get }
    var playListItemsTextColor: UIColor { get }
    var playListCurrentItemFont: UIFont { get }
    var playListItemsFont: UIFont { get }
    var timeLabelTextColor: UIColor { get }
    var sliderTintColor: UIColor { get }
    var sliderThumbColor: UIColor { get }
    var activityViewColor: UIColor { get }
    var playListItemsBackgroundColor: UIColor { get }
    
    var resizeButtonImage: UIImage! { get }
    var playButtonImage: UIImage! { get }
    var pauseButtonImage: UIImage! { get }
    var forwardButtonImage: UIImage! { get }
    var backButtonImage: UIImage! { get }
    var optionsButtonImage: UIImage! { get }
}

public struct MainTheme: MBTheme {
    public var headerBackgroundOpacity: Float = 0.3
    public var buttonTintColor: UIColor = .white
    public var headerBackgroundColor: UIColor = .gray
    public var playListCurrentItemTextColor: UIColor = .white
    public var playListItemsTextColor: UIColor = .white
    public var timeLabelTextColor: UIColor = .white
    public var sliderTintColor: UIColor = .white
    public var sliderThumbColor: UIColor = .white
    public var activityViewColor: UIColor = .white
    public var playListItemsBackgroundColor: UIColor = .clear
    public var playListCurrentItemFont = UIFont.systemFont(ofSize: 17.0)
    public var playListItemsFont = UIFont.systemFont(ofSize: 12.0)

    public var resizeButtonImage: UIImage! = Controls.resize(.fullScreen).image
    public var playButtonImage: UIImage! = Controls.playpause(false).image
    public var pauseButtonImage: UIImage! = Controls.playpause(true).image
    public var forwardButtonImage: UIImage! = Controls.forward.image
    public var backButtonImage: UIImage! = Controls.back.image
    public var optionsButtonImage: UIImage! = Controls.options.image
    
}
