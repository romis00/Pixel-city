//
//  DroppablePin.swift
//  Pixel-city
//
//  Created by Roman Tuzhilkin on 7/21/20.
//  Copyright © 2020 Roman Tuzhilkin. All rights reserved.
//

import Foundation
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
