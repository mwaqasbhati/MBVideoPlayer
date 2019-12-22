# MBVideoPlayer

A video player on top of AVQueuePlayer with custom header, playlist items, play, pause, seek to slider, time, resize to fullscreen, forward, backward horizontal, vertical capabilities.

|             Portrait         |         Portrait Full Screen          | Landscape Full Screen | 
|---------------------------------|------------------------------|------------------------------|
|![Demo](https://github.com/mwaqasbhati/MBVideoPlayer/blob/master/screenshots/portrait.png)|![Demo](https://github.com/mwaqasbhati/MBVideoPlayer/blob/master/screenshots/portrait_fullscreen.png)|![Demo](https://github.com/mwaqasbhati/MBVideoPlayer/blob/master/screenshots/fullscreen.png)|


## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Example](#example)
- [Installation](#installation)
- [Usage](#usage)
- [Demo](#demo)
- [Contact](#contact)
- [Contribution](#contribution)
- [License](#license)

## Features

 - ✅ Support Both Horizontal and Vertical Orientation. 
 - ✅ Custom Header view which in configurable.
 - ✅ Custom Theme which will control your player colors, fonts etc.
 - ✅ Custom Configuration which will control player settings.
 - ✅ Can be embedded within a view or be presented in full screen.
 - ✅ option to add custom playlist with title and thumbnail.
 - ✅ Include play, pause, forward, backward, fullscreen, timer and playlist functionalities.

## Requirements

- iOS 13.0
- Swift 5.0

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### Manually


### CocoaPods

MBVideoPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MBVideoPlayer', :git => 'https://github.com/mwaqasbhati/MBVideoPlayer.git'
```

## Usage

We can initialize it via Storyboard as well as from the code.

### Using StoryBoard

First of all assign class `MBVideoPlayer` to UIView in Storyboard and then make an out of it. 
    `@IBOutlet weak var videoPlayerView: MBVideoPlayerView!`
then create playlist using below code.

### Using Code

```swift
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
                
        view.addSubview(playerView)
        playerView.pinEdges(to: view)
```

### Custom CallBacks

```swift
protocol MBVideoPlayerViewDelegate: class {
    var playerStateDidChange: ((MBVideoPlayerState)->())? {get set}
    var playerTimeDidChange: ((TimeInterval, TimeInterval)->())? {get set}
    var playerOrientationDidChange: ((PlayerDimension) -> ())? {get set}
    var playerDidChangeSize: ((PlayerDimension) -> ())? {get set}
    var playerCellForItem: (()->(UICollectionViewCell))? {get set}
    var playerDidSelectItem: ((IndexPath)->())? {get set}
}
```
### Custom Configuration

```swift
public protocol MBConfiguration {
    var canShowVideoList: Bool { get }
    var canShowTime: Bool { get }
    var canShowPlayPause: Bool { get }
    var canShowTimeBar: Bool { get }
    var canShowFullScreenBtn: Bool { get }
    var canShowForwardBack: Bool { get }
    var canShowHeader: Bool { get }
    var canShowHeaderTitle: Bool { get }
    var canShowHeaderOption: Bool { get }
    var dimension: PlayerDimension { get }
    var seekDuration: Float64 { get }
}
```

### Custom Theme

```swift
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
```
## Demo

<p align="center">
  <img width="30%" height="30%" src="/screenshots/demo.gif">
</p>

## Contact

Email: m.waqas.bhati@hotmail.com

Blog: https://medium.com/@wqsbhtt/mbvideoplayer-2ec2bf292574

## Contribution

1- Fork it!

2- Create your feature branch: git checkout -b my-new-feature

3- Commit your changes: git commit -am 'Add some feature'

4- Push to the branch: git push origin my-new-feature

5- Submit a pull request

## License

MBVideoPlayer is available under the MIT license. See the LICENSE file for more info.
