//
//  PlayerItem.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/9/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation

/// data model for video playlist item

public struct PlayerItem {
    let title: String
    let url: String
    let thumbnail: String
    
    public init(title:String, url: String, thumbnail: String) {
        self.title = title
        self.url = url
        self.thumbnail = thumbnail
    }
}
