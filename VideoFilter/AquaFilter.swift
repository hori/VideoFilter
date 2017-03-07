//
//  AquaFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/06.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class AquaFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return AquaFilter()
  }
}

class AquaFilter: GPUImageFilterGroup {
  
  let colorRemapImage: String = "filter_aqua"
  let toneAcv: String = "filter_aqua"
  
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
    
    self.initialFilters = [lookupFilter]
    self.terminalFilter = toneCorveFilter
  }
  
}
