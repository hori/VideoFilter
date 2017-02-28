//
//  ViewController.swift
//  VideoFilter
//
//  Created by hor on 2017/02/23.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

class ViewController: UIViewController {

  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var exportButton: UIButton!

  var player: AVPlayer! = nil
  var playerItem: AVPlayerItem! = nil
  var videoFrameSize: CGSize?
  var originalAsset: AVAsset?
  
  var encodingMovieWriter: GPUImageMovieWriter?
  var encodingMovie: GPUImageMovie?
  var encodingFilter: GPUImageFilterGroup?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let path = Bundle.main.path(forResource: "snowboarding_480p", ofType: "m4v")
    player = AVPlayer()
    let pathUrl = NSURL.fileURL(withPath: path!)
    
    originalAsset = AVAsset(url: pathUrl)
    let videoTrack = originalAsset?.tracks(withMediaType: AVMediaTypeVideo).first
    videoFrameSize = videoTrack?.naturalSize
      
    playerItem = AVPlayerItem(url: pathUrl)
    player.replaceCurrentItem(with: playerItem)
    
    let gpuMovie: GPUImageMovie! = GPUImageMovie(playerItem: playerItem)
    gpuMovie.playAtActualSpeed = true
    
    let filteredView: GPUImageView = GPUImageView();
    filteredView.frame = self.view.frame
    filteredView.setInputRotation(kGPUImageRotateRight, at: 0)
    filteredView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
    previewView.addSubview(filteredView)
    print(filteredView.frame)
    print(filteredView.sizeInPixels)

    let dynamicFilter = DynamicFilter.init()
    gpuMovie.addTarget(dynamicFilter)
    gpuMovie.playAtActualSpeed = true
    dynamicFilter.addTarget(filteredView)
    
    gpuMovie.startProcessing()

    
    
    
    
    
    player.play()

    // loop video
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
      DispatchQueue.main.async {
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
      }
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func beginExport(sender: AnyObject) {
  
    let documentDirPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
    let exportPath = documentDirPath + "/export.mov"
    let exportUrl = URL.init(fileURLWithPath: exportPath)
    print(exportUrl)
    player.pause()
    
    encodingMovieWriter = GPUImageMovieWriter.init(movieURL: exportUrl, size: videoFrameSize! )

    print(videoFrameSize)
    
    encodingMovie = GPUImageMovie.init(asset: originalAsset)
    encodingFilter = DynamicFilter.init()
    encodingMovie?.addTarget(encodingFilter)
    encodingFilter?.addTarget(encodingMovieWriter)
    encodingMovieWriter?.shouldPassthroughAudio = true
    encodingMovie?.audioEncodingTarget = encodingMovieWriter
    encodingMovie?.enableSynchronizedEncoding(using: encodingMovieWriter)
    
    encodingMovieWriter?.completionBlock = {() -> Void in
      print("completed")
      self.encodingMovieWriter?.finishRecording()
      self.encodingMovie?.cancelProcessing()
      self.encodingMovie?.removeAllTargets()
      self.encodingFilter?.removeAllTargets()
    }
    encodingMovieWriter?.startRecording()
    encodingMovie?.startProcessing()
    
  }
  

}

