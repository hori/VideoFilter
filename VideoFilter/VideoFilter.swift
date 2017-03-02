//
//  VideoFilter.swift
//  VideoFilter
//
//  Created by hor on 2017/03/02.
//  Copyright © 2017年 dope.industries. All rights reserved.
//

import Foundation
import GPUImage

struct VideoFilter {
  var name: String
  var filter: GPUImageFilterGroup?
}

let VideoFilters: [VideoFilter] = [
  VideoFilter(name: "Dynamic", filter: DynamicFilter()),
  VideoFilter(name: "Elegance", filter: EleganceFilter()),
  VideoFilter(name: "Dynamic2", filter: DynamicFilter()),
  VideoFilter(name: "Elegance2", filter: EleganceFilter()),
  VideoFilter(name: "Dynamic3", filter: DynamicFilter()),
  VideoFilter(name: "Elegance4", filter: EleganceFilter())
]
