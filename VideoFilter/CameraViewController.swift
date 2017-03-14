//
//  CameraViewController.swift
//  VideoFilter
//
//  Created by hor on 2017/03/13.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
  
  let session = AVCaptureSession()
  var videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
  let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
  let fileOutput = AVCaptureMovieFileOutput()

  var isCaptureing = false
  
  @IBOutlet weak var captureButton: UIButton!
  @IBOutlet weak var previewView: UIView!


  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    session.stopRunning()
    for gesture in previewView.gestureRecognizers! {
      previewView.removeGestureRecognizer(gesture)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.setupCaptureSession()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("didReceiveMemoryWarning")
    // Dispose of any resources that can be recreated.
  }
  
  func setupCaptureSession(){

    do {
      
      for anyformat in (videoDevice?.formats)! {
        let format = anyformat as! AVCaptureDeviceFormat
        let fpsRange = format.videoSupportedFrameRateRanges as! [AVFrameRateRange]
        let maxFps = fpsRange[0].maxFrameRate
        print(format.formatDescription)
        print(maxFps)
        print(
          format.isVideoStabilizationModeSupported(AVCaptureVideoStabilizationMode.cinematic),
          format.isVideoStabilizationModeSupported(AVCaptureVideoStabilizationMode.auto),
          format.isVideoStabilizationModeSupported(AVCaptureVideoStabilizationMode.standard)
        )
        print("---")
        
        if maxFps == 60 && format.isVideoStabilizationModeSupported(AVCaptureVideoStabilizationMode.cinematic) {
          try videoDevice?.lockForConfiguration()
          videoDevice?.activeFormat = format
          videoDevice?.activeVideoMinFrameDuration = CMTimeMake(1,60)
          videoDevice?.activeVideoMaxFrameDuration = CMTimeMake(1,60)
          videoDevice?.unlockForConfiguration()
          break
        }
      }

      let videoInput = try AVCaptureDeviceInput.init(device: videoDevice)
      let audioInput = try AVCaptureDeviceInput.init(device: audioDevice)
      
      session.addInput(videoInput)
      session.addInput(audioInput)

    } catch {
      print("catch")
    }
    
    session.addOutput(fileOutput)

    // Stabilization
    let connection: AVCaptureConnection? = fileOutput.connection(withMediaType: AVMediaTypeVideo)
    connection!.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.cinematic

    // Preview
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer?.masksToBounds = true
    previewLayer?.frame = previewView.bounds
    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    previewView.layer.addSublayer(previewLayer!)
    
    // Touch AF & AE
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tapPreviewView(gestureRecognizer:)))
    previewView.addGestureRecognizer(gesture)

    
    session.startRunning()

    print("---")
    print(CMTimeMake(1,60))
    print(videoDevice?.activeVideoMinFrameDuration)
    print(videoDevice?.activeVideoMaxFrameDuration)
    print("---")
    
    
  }

  func tapPreviewView(gestureRecognizer : UITapGestureRecognizer){
    let origin = gestureRecognizer.location(in: previewView)
    let focusPoint = CGPoint(x: origin.y / previewView.bounds.size.height, y: 1 - origin.x / previewView.bounds.size.width);
    self.setFocusAndrExposure(focusPoint: focusPoint)
    print(focusPoint)
  }
  
  func setFocusAndrExposure(focusPoint: CGPoint) {
    do{
      try videoDevice?.lockForConfiguration()
      videoDevice?.focusPointOfInterest = focusPoint
      videoDevice?.focusMode = AVCaptureFocusMode.autoFocus
      
      if (videoDevice?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure))! {
        videoDevice?.exposurePointOfInterest = focusPoint
        videoDevice?.exposureMode = AVCaptureExposureMode.autoExpose
      }
      videoDevice?.unlockForConfiguration()
    }catch{
    }
  }

  @IBAction func startCapture(_ sender:AnyObject) {
    if isCaptureing {
      isCaptureing = false
      AudioServicesPlaySystemSound(1118)
      self.finishRecording()
    }else{
      isCaptureing = true
      AudioServicesPlaySystemSound(1117)
      self.startRecording()
    }
  }
  
  func startRecording() {
    let url = self.urlOfRecordMovie()
    fileOutput.startRecording(toOutputFileURL: url, recordingDelegate: self)
    isCaptureing = true
  }
  
  func finishRecording() {
    fileOutput.stopRecording()
    isCaptureing = false
  }

  func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!){
    print("finish capture")
    self.shareWithAirDrop()
  }
  
  func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    print("start capture")
  }
  
  
}

extension CameraViewController {

  fileprivate func urlOfRecordMovie() -> URL {
    let manager = FileManager.default
    let fileName = "record.mov"
    let dir: URL! = manager.urls(for: .documentDirectory, in: .userDomainMask).last
    let filePath = dir.appendingPathComponent(fileName)
    return filePath.absoluteURL
  }
  
  fileprivate func removeRecordMovie() {
    let manager = FileManager.default
    let fileUrl = self.urlOfRecordMovie()
    if manager.fileExists(atPath: fileUrl.path)  {
      do {
        try manager.removeItem(atPath: fileUrl.path)
      } catch {}
    }
  }

  //MARK: - for Debugging
  fileprivate func shareWithAirDrop() {
    let fileUrl = self.urlOfRecordMovie()
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
