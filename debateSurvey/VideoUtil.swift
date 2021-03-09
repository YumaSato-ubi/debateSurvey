//
//  VideoUtil.swift
//  debateSurvey
//
//  Created by 佐藤佑磨 on 2021/02/11.
//  Copyright © 2021 Wataru Sasaki. All rights reserved.
//

import UIKit
import AVKit

class VideoUtil: UIView {
    var player: AVPlayer?{
        get { return playerLayer.player}
        set { playerLayer.player = newValue}
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
