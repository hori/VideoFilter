//
//  VideoFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/02.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import Foundation
import GPUImage

protocol VideoFilterClass: class {
  func instantiate() -> GPUImageFilterGroup
}

struct VideoFilter {
  var name: String
  var filterClass: VideoFilterClass?
}

let VideoFilters: [VideoFilter] = [
  VideoFilter(name: "Original", filterClass: OriginalFilterClass()),
  VideoFilter(name: "Echo", filterClass: EchoFilterClass()),
  VideoFilter(name: "Dynamic", filterClass: DynamicFilterClass()),
  VideoFilter(name: "Elegance", filterClass: EleganceFilterClass()),
  VideoFilter(name: "Aqua", filterClass: AquaFilterClass()),
  VideoFilter(name: "Light", filterClass: LightFilterClass()),
  VideoFilter(name: "Toy", filterClass: ToyFilterClass()),
  VideoFilter(name: "Antique", filterClass: AntiqueFilterClass())
]
