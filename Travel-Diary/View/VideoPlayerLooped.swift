//
//  VideoPlayerLooped.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/6.
//

import Foundation
import AVKit

class VideoPlayerLooped {

    public var videoPlayer: AVQueuePlayer?
    public var videoPlayerLayer: AVPlayerLayer?
    var playerLooper: NSObject?
    var queuePlayer: AVQueuePlayer?

    func playVideo(fileName: String, inView: UIView) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp4") else {
            return
        }
        
        let player = AVQueuePlayer()
        let item = AVPlayerItem(url: URL(fileURLWithPath: path))
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
    
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer!.frame = inView.bounds
        videoPlayerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        inView.layer.addSublayer(videoPlayerLayer!)
        
        videoPlayer?.play()
    }

    func remove() {
        videoPlayerLayer?.removeFromSuperlayer()
    }
}
