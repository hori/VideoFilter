//
//  EleganceFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/02.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class EleganceFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return EleganceFilter()
  }
  func thumbnailFilterInstantiate() -> GPUImageFilterGroup {
    return EleganceFilter()
  }
}

class EleganceFilter: GPUImageFilterGroup {
  
  let colorRemapImage: String = "filter_elegance"
  let toneAcv: String = "filter_elegance"
  
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
