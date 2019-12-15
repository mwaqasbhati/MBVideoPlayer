//
//  MBTheme.swift
//  MBVideoPlayer
//
//  Created by Muhammad Waqas on 15/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

public protocol MBTheme {
    var buttonTintColor: UIColor { get }
    var headerBackgroundColor: UIColor { get }
    var headerBackgroundOpacity: Float { get }
    var titleLabelTextColor: UIColor { get }
    var timeLabelTextColor: UIColor { get }
    var sliderTintColor: UIColor { get }
    var sliderThumbColor: UIColor { get }
}

public struct MainTheme: MBTheme {
    public var headerBackgroundOpacity: Float = 0.3
    public var buttonTintColor: UIColor = .white
    public var headerBackgroundColor: UIColor = .black
    public var titleLabelTextColor: UIColor = .white
    public var timeLabelTextColor: UIColor = .white
    public var sliderTintColor: UIColor = .white
    public var sliderThumbColor: UIColor = .white
}
