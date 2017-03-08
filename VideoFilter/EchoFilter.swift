//
//  EchoFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/06.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class EchoFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return EchoFilter()
  }
  func thumbnailFilterInstantiate() -> GPUImageFilterGroup {
    return EchoFilterForThumbnail()
  }
}

class EchoFilter: GPUImageFilterGroup {
  
  public override init(){
    super.init()
    
    let lowpassFilter = GPUImageLowPassFilter.init()
    self.addFilter(lowpassFilter)
    
    self.initialFilters = [lowpassFilter]
    self.terminalFilter = lowpassFilter
  }
  
}

class EchoFilterForThumbnail: GPUImageFilterGroup {
  
  public override init(){
    super.init()
    
    let filter = GPUImageBoxBlurFilter.init()
    self.addFilter(filter)
    
    self.initialFilters = [filter]
    self.terminalFilter = filter
  }
  
}
