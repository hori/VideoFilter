//
//  TwinkleFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/13.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class TwinkleFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return TwinkleFilter()
  }
  func thumbnailFilterInstantiate() -> GPUImageFilterGroup {
    return TwinkleFilterForThumbnail()
  }
}

class TwinkleFilter: GPUImageFilterGroup {
  
  let blendMovieName: String = "blend_twinkle"
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

class TwinkleFilterForThumbnail: GPUImageFilterGroup {
  
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
