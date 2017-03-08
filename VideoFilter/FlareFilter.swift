//
//  FlareFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/07.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class FlareFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return FlareFilter()
  }
  func thumbnailFilterInstantiate() -> GPUImageFilterGroup {
    return FlareFilterForThumbnail()
  }
}

class FlareFilter: GPUImageFilterGroup {
  
  let colorRemapImage: String = "filter_dynamic"
  let toneAcv: String = "filter_dynamic"
  
  public var lookupImageSource: GPUImagePicture!
  public var flareMovie: GPUImageMovie!

  public override init(){
    super.init()
    
    let lookupImage = UIImage(named: colorRemapImage)
    self.lookupImageSource = GPUImagePicture.init(image: lookupImage)
    let lookupFilter = GPUImageLookupFilter.init()
    lookupFilter.intensity = 1.0
    self.addFilter(lookupFilter)
    
    lookupImageSource.addTarget(lookupFilter, atTextureLocation: 1)
    lookupImageSource.processImage()
    
    let acvURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: toneAcv, ofType: "acv")!)
    let toneCorveFilter = GPUImageToneCurveFilter.init(acvurl: acvURL)
    lookupFilter.addTarget(toneCorveFilter)
    self.addFilter(toneCorveFilter)
    
    let path = Bundle.main.path(forResource: "overlay_flare", ofType: "mp4")
    flareMovie = GPUImageMovie.init(url: NSURL.fileURL(withPath: path!))
    flareMovie.playAtActualSpeed = true

    let screenBlendFilter = GPUImageScreenBlendFilter.init()
    
    toneCorveFilter?.addTarget(screenBlendFilter)
    flareMovie?.addTarget(screenBlendFilter)
    self.addFilter(screenBlendFilter)
    flareMovie?.startProcessing()
    
    self.initialFilters = [lookupFilter]
    self.terminalFilter = screenBlendFilter
  }
  
}

class FlareFilterForThumbnail: GPUImageFilterGroup {

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
