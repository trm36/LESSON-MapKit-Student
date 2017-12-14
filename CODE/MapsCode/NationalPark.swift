//
//  NationalPark.swift
//  MapsCode
//
//  Created by Taylor Mott on 13-Dec-17.
//  Copyright © 2017 Mott Applications. All rights reserved.
//

import Foundation
import MapKit

class NationalPark: NSObject, MKAnnotation {
    
    //National Park Properties
    var name: String
    
    //National Park Methods
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
        super.init()
    }
    
    // MARK: - MKAnnotation Protocol
    var coordinate: CLLocationCoordinate2D
    var title: String? {
        get { return name }
    }
}
