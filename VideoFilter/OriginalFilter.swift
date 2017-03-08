//
//  OriginalFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/06.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import GPUImage

class OriginalFilterClass: VideoFilterClass {
  func instantiate() -> GPUImageFilterGroup {
    return OriginalFilter()
  }
  func thumbnailFilterInstantiate() -> GPUImageFilterGroup {
    return OriginalFilter()
  }
}

class OriginalFilter: GPUImageFilterGroup {
  
  public override init(){
    super.init()
    
    let toneCorveFilter = GPUImageToneCurveFilter.init()
    self.addFilter(toneCorveFilter)
    
    self.initialFilters = [toneCorveFilter]
    self.terminalFilter = toneCorveFilter
  }
  
}
