//
//  PhotoParser.swift
//  Nasa App
//
//  Created by Lucas Daniel on 23/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation

struct PhotosParser: Codable {
    let photos: [Photos]
}

struct Photos: Codable {
    let earth_date: String?
    let img_src: String?
}
