//
//  SunshineFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/07.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class SunshineFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return SunshineFilter()
  }
  func thumbnailFilterInstantiate() -> GPUImageFilterGroup {
    return SunshineFilterForThumbnail()
  }
}

class SunshineFilter: GPUImageFilterGroup {
  
  let blendMovieName: String = "blend_sunshine"
  public var blendMovie: GPUImageMovie?
  
  public override init(){
    super.init()
    
    let toneCorveFilter = GPUImageToneCurveFilter.init()
    self.addFilter(toneCorveFilter)
    
    let path = Bundle.main.path(forResource: blendMovieName, ofType: "mp4")
    blendMovie = GPUImageMovie.init(url: NSURL.fileURL(withPath: path!))
    blendMovie?.playAtActualSpeed = true
    blendMovie?.shouldRepeat = true
    
    let blendFilter = GPUImageOverlayBlendFilter.init()
    toneCorveFilter.addTarget(blendFilter)
    blendMovie?.addTarget(blendFilter)
    
    self.addFilter(blendFilter)
    blendMovie?.startProcessing()
    
    self.initialFilters = [toneCorveFilter]
    self.terminalFilter = blendFilter


  }
  
  override func removeAllTargets() {
    blendMovie?.cancelProcessing()
    blendMovie?.removeAllTargets()
    super.removeAllTargets()
  }
  
}

class SunshineFilterForThumbnail: GPUImageFilterGroup {

  let colorRemapImageName: String = "filter_dynamic"
  let toneAcvName: String = "filter_dynamic"
  let flareImageName: String = "overlay_toy"
  
  public var lookupImageSource: GPUImagePicture!
  public var overlayImageSource: GPUImagePicture!
  
  public override init(){
    super.init()
    
    let lookupImage = UIImage(named: colorRemapImageName)
    lookupImageSource = GPUImagePicture.init(image: lookupImage)
    let lookupFilter = GPUImageLookupFilter.init()
    lookupFilter.intensity = 1.0
    self.addFilter(lookupFilter)
    
    lookupImageSource.addTarget(lookupFilter, atTextureLocation: 1)
    lookupImageSource.processImage()
    
    let acvURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: toneAcvName, ofType: "acv")!)
    let toneCorveFilter = GPUImageToneCurveFilter.init(acvurl: acvURL)
    lookupFilter.addTarget(toneCorveFilter)
    self.addFilter(toneCorveFilter)
    
    let flareImage = UIImage(named: flareImageName)
    overlayImageSource = GPUImagePicture.init(image: flareImage)
    let overlayFilter = GPUImageOverlayBlendFilter.init()
    toneCorveFilter?.addTarget(overlayFilter)
    self.addFilter(overlayFilter)
    
    overlayImageSource.addTarget(overlayFilter, atTextureLocation: 1)
    overlayImageSource.processImage()
    
    self.initialFilters = [lookupFilter]
    self.terminalFilter = overlayFilter
  }
}
