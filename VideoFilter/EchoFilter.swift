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
