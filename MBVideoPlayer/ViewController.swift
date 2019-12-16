//
//  ViewController.swift
//  MBVideoPlayer
//
//  Created by Muhammad Waqas on 06/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MBVideoPlayerViewDelegate {

    let playerView = MBVideoPlayerView(configuration: MainConfiguration(), theme: MainTheme())
    
    @IBOutlet weak var videoPlayerView: MBVideoPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let videos = ["http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
                      "https://content.jwplatform.com/manifests/yp34SRmf.m3u8",
                      "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                      "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8",
                      "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"]
        
        playerView.playerStateDidChange = { (state) in
            
        }
        playerView.playerOrientationDidChange = { (orientation) in
        
        }
        let items = videos.map({ (video) -> PlayerItem in
            return PlayerItem(title: "Some Test Title", url: video, thumbnail: "")
        })
        if let item = items.first {
            playerView.setPlayListItemsWith(delegate: self, currentItem: item, items: items, fullView: view)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    

}

// MARK: - MBPlayerViewDelegate

//extension ViewController: MBVideoPlayerViewDelegate {
//
//}

