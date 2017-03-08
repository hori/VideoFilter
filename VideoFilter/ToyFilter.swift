//
//  ToyFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/06.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class ToyFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return ToyFilter()
  }
  func thumbnailFilterInstantiate() -> GPUImageFilterGroup {
    return ToyFilter()
  }
}

class ToyFilter: GPUImageFilterGroup {
  
  let colorRemapImageName: String = "filter_toy"
  let toneAcvName: String = "filter_toy"
  let vignetteImageName: String = "overlay_toy"
  
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

    let vignetteImage = UIImage(named: vignetteImageName)
    overlayImageSource = GPUImagePicture.init(image: vignetteImage)
    let overlayFilter = GPUImageOverlayBlendFilter.init()
    toneCorveFilter?.addTarget(overlayFilter)
    self.addFilter(overlayFilter)

    overlayImageSource.addTarget(overlayFilter, atTextureLocation: 1)
    overlayImageSource.processImage()
    
    self.initialFilters = [lookupFilter]
    self.terminalFilter = overlayFilter
  }
  
}
