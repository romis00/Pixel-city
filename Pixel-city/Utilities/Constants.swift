//
//  Constants.swift
//  Pixel-city
//
//  Created by Roman Tuzhilkin on 7/20/20.
//  Copyright © 2020 Roman Tuzhilkin. All rights reserved.
//

import Foundation

struct CONSTANTS {
    static let instance = CONSTANTS()
    
    let regionRadius: Double = 1000
    let pinnedRegionRadius: Double = 400
    let mapViewMoveUpFor: Double = 300
    
    let pinIdentifier: String = "droppablePin"
    let cellIdentifier: String = "photoCell"
    
    let apiKey = "d14825f5485f15ff57483a856908e7da"
    
    func flickrURL(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
        let url =  "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
        return url
    }
    
}

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=10f4f77631339895da490264a15ec85c&lat=42.8&lon=122.3&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1
