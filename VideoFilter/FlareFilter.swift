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
}

class FlareFilter: GPUImageFilterGroup {
  
  let colorRemapImage: String = "filter_dynamic"
  let toneAcv: String = "filter_dynamic"
  
  public var lookupImageSource: GPUImagePicture!
  
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
    let flareMovie = GPUImageMovie.init(url: NSURL.fileURL(withPath: path!))
    flareMovie?.playAtActualSpeed = true
    let screenBlendFilter = GPUImageScreenBlendFilter.init()
    
    toneCorveFilter?.addTarget(screenBlendFilter)
    flareMovie?.addTarget(screenBlendFilter)
    self.addFilter(screenBlendFilter)
    flareMovie?.startProcessing()
    
    self.initialFilters = [lookupFilter]
    self.terminalFilter = screenBlendFilter
  }
  
}
