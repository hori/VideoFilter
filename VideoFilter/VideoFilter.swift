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
//  VideoFilter(name: "Original", filterClass: nil),
  VideoFilter(name: "Dynamic", filterClass: DynamicFilterClass()),
  VideoFilter(name: "Elegance", filterClass: EleganceFilterClass()),
  VideoFilter(name: "Dynamic2", filterClass: DynamicFilterClass()),
  VideoFilter(name: "Elegance2", filterClass: EleganceFilterClass()),
  VideoFilter(name: "Dynamic3", filterClass: DynamicFilterClass()),
  VideoFilter(name: "Elegance4", filterClass: EleganceFilterClass())
]
