//
//  PlayerView.swift
//  VideoFilter
//
//  Created by hor on 2017/02/23.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class PlayerView: UIView {
  var player: AVPlayer? {
    get {
      return playerLayer.player
    }
    set {
      playerLayer.player = newValue
    }
  }
  
  var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }
  
  // Override UIView property
  override static var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
}
