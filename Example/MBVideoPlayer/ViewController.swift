//
//  ViewController.swift
//  MBVideoPlayer
//
//  Created by Muhammad Waqas on 06/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit
import MBVideoPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var videoPlayerView: MBVideoPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let playerView = MBVideoPlayerView(configuration: nil, theme: nil, header: nil)

        let playerItems = [
            PlayerItem(title: "Apple Live Broadcast WWDC.", url: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8", thumbnail: "1"),
            PlayerItem(title: "Driving a Cycle experience.", url: "https://content.jwplatform.com/manifests/yp34SRmf.m3u8", thumbnail: "2"),
            PlayerItem(title: "The Durian Open Movie Project.", url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", thumbnail: "3"),
            PlayerItem(title: "Table Ronde.", url: "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8", thumbnail: "4"),
            PlayerItem(title: "What is this event? ... parker.", url: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8", thumbnail: "5")
        ]
        
        if let currentItem = playerItems.first {
            videoPlayerView.setPlayList(currentItem: currentItem, items: playerItems, fullScreenView: view)
        }
        
       // playerView.didRegisterPlayerItemCell("videoCellId1", collectioViewCell: VideoCollectionViewCell.self)
        
        view.addSubview(playerView)
        
        playerView.pinEdges(to: view)
        
        playerView.playerStateDidChange = { (state) in
            
        }
        playerView.playerOrientationDidChange = { (orientation) in
        
        }
        playerView.playerDidChangeSize = { (dimension) in
            
        }
        playerView.playerTimeDidChange = { (newTime, duration) in
            
        }
//        playerView.playerCellForItem = { (collectioView, indexPath) -> UICollectionViewCell in
//            let cell = collectioView.dequeueReusableCell(withReuseIdentifier: "videoCellId1", for: indexPath) as! VideoCollectionViewCell
//            cell.setData(playerItems[indexPath.row])
//            return cell
//        }
        playerView.playerDidSelectItem = { (index) in
            
        }
        videoPlayerView.didSelectOptions = { (index) in
            let controller = UIAlertController(title: "Options", message: "select below options", preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "Save video", style: .default) { (action) in
                
            }
            let action2 = UIAlertAction(title: "Mark as spam", style: .default) { (action) in
                
            }
            let action3 = UIAlertAction(title: "Delete video", style: .default) { (action) in
                
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
            }
            controller.addAction(action1)
            controller.addAction(action2)
            controller.addAction(action3)
            controller.addAction(cancel)
            self.present(controller, animated: true, completion: nil)
            
        }
        
    }
        
}


