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
import Accounts

class ViewController: UIViewController {

  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var exportButton: UIButton!
  @IBOutlet weak var filterCollectionView: UICollectionView!

  var player: AVPlayer! = nil
  var playerItem: AVPlayerItem! = nil
  var videoFrameSize: CGSize?
  var originalAsset: AVAsset?
  var originalThumbnail: UIImage?
  var thumbnails: [UIImage?] = []
  
  var renderingMovieWriter: GPUImageMovieWriter?
  var renderingMovie: GPUImageMovie?
  var renderingFilter: GPUImageFilterGroup? = nil {
    willSet{
      previewingFilter?.removeAllTargets()
    }
  }

  var previewingMovie: GPUImageMovie!
  let previewingView = GPUImageView()
  
  var previewingFilter: GPUImageFilterGroup? = nil {
    willSet{
      previewingFilter?.removeAllTargets()
      previewingMovie.removeAllTargets()
    }
    didSet{
      previewingView.setInputRotation(kGPUImageRotateRight, at: 0) // TODO: detect original assets orientation
      previewingView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
      previewingMovie.addTarget(previewingFilter)
      previewingMovie.playAtActualSpeed = true
      previewingFilter?.addTarget(previewingView)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let path = Bundle.main.path(forResource: "snowboarding_480p", ofType: "m4v")
    player = AVPlayer()
    let pathUrl = NSURL.fileURL(withPath: path!)
    
    originalAsset = AVAsset(url: pathUrl)
    let videoTrack = originalAsset?.tracks(withMediaType: AVMediaTypeVideo).first
    videoFrameSize = videoTrack?.naturalSize
    
    DispatchQueue.global(qos: .default).async {
      self.originalThumbnail = self.thumbnail()
      self.thumbnails = self.previewThumbnails()
      DispatchQueue.main.async {
        self.filterCollectionView.reloadData()
      }
    }
      
    playerItem = AVPlayerItem(url: pathUrl)
    player.replaceCurrentItem(with: playerItem)
    
    previewingMovie = GPUImageMovie(playerItem: playerItem)
    previewingMovie.playAtActualSpeed = true
    
    previewingView.frame = self.view.frame
    previewingView.setInputRotation(kGPUImageRotateRight, at: 0) // TODO: detect original assets orientation
    previewingView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
    previewView.addSubview(previewingView)
    print(previewingView.frame)
    print(previewingView.sizeInPixels)

    previewingFilter = VideoFilters[0].filterClass?.instantiate()
    
    previewingMovie.startProcessing()

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
  
  //MARK: - for Export
  
  @IBAction func beginExport(_ sender: AnyObject) {

    if renderingFilter == nil {
      return
    }
    
    self.removeRenderdMovie()
    let exportUrl = self.urlOfRenderdMovie()
    print(exportUrl)
    player.pause()
    
    // TODO: detect original assets orientation
    renderingMovieWriter = GPUImageMovieWriter.init(movieURL: exportUrl, size: CGSize(width: videoFrameSize!.height, height: videoFrameSize!.width))
    renderingMovieWriter?.setInputRotation(kGPUImageRotateRight, at: 0)
    
    renderingMovie = GPUImageMovie.init(asset: originalAsset)
    renderingMovie?.addTarget(renderingFilter)
    renderingFilter?.addTarget(renderingMovieWriter)
    renderingMovieWriter?.shouldPassthroughAudio = true
    renderingMovie?.audioEncodingTarget = renderingMovieWriter
    renderingMovie?.enableSynchronizedEncoding(using: renderingMovieWriter)
    
    renderingMovieWriter?.completionBlock = {() -> Void in
      print("completed")
      self.renderingMovieWriter?.finishRecording()
      self.renderingMovie?.cancelProcessing()
      self.renderingMovie?.removeAllTargets()
      self.renderingFilter?.removeAllTargets()
      self.shareWithAirDrop()
    }
    renderingMovieWriter?.startRecording()
    renderingMovie?.startProcessing()
    
  }
  
  fileprivate func urlOfRenderdMovie() -> URL {
    let manager = FileManager.default
    let fileName = "renderd.mov"
    let dir: URL! = manager.urls(for: .documentDirectory, in: .userDomainMask).last
    let filePath = dir.appendingPathComponent(fileName)
    return filePath.absoluteURL
  }
  
  fileprivate func removeRenderdMovie() {
    let manager = FileManager.default
    let fileUrl = self.urlOfRenderdMovie()
    if manager.fileExists(atPath: fileUrl.path)  {
      do {
        try manager.removeItem(atPath: fileUrl.path)
      } catch {}
    }
  
  }

  fileprivate func thumbnail() -> UIImage? {
    guard let asset = originalAsset else { return nil }
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    let cgimage: CGImage
    do {
      cgimage = try generator.copyCGImage(at: kCMTimeZero, actualTime: nil)
    } catch {
      return nil
    }
    let thumbnail = UIImage(cgImage: cgimage)
    return thumbnail
  }

  fileprivate func previewThumbnails() -> [UIImage?] {
    guard let original = originalThumbnail else { return [] }
    var thumbnails:[UIImage?] = []
    for videoFilter in VideoFilters {
      print(videoFilter.filterClass)
      if let filter = videoFilter.filterClass?.instantiate(),
         let image = GPUImagePicture(image: original)
      {
        image.addTarget(filter)
        filter.useNextFrameForImageCapture()
        image.processImage()
        let cgimage: CGImage? = filter.newCGImageFromCurrentlyProcessedOutput().takeUnretainedValue()
        thumbnails.append(UIImage(cgImage: cgimage!))
      } else {
        thumbnails.append(original)
      }
    }
    return thumbnails
  }

  //MARK: - for Debugging
  
  fileprivate func shareWithAirDrop() {
    let fileUrl = self.urlOfRenderdMovie()
    let activityVC = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
    activityVC.excludedActivityTypes = [
      .postToFacebook,
      .postToTwitter,
      .postToWeibo,
      .message,
      .mail,
      .print,
      .copyToPasteboard,
      .assignToContact,
      .addToReadingList,
      .postToFlickr,
      .postToVimeo,
      .postToTencentWeibo,
      .openInIBooks
    ]
    self.present(activityVC, animated: true, completion: nil)
  }
}


//MARK: - CollectonView
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return thumbnails.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    print(indexPath.row)
    let videoFilter = VideoFilters[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath)

    let label = cell.contentView.viewWithTag(2) as! UILabel
    label.text = videoFilter.name

    let imageView = cell.contentView.viewWithTag(1) as! UIImageView
    imageView.image = thumbnails[indexPath.row]

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    previewingFilter = VideoFilters[indexPath.row].filterClass?.instantiate()
    renderingFilter = VideoFilters[indexPath.row].filterClass?.instantiate()
  }
}

