//
//  Annonation.swift
//  MapsCode
//
//  Created by Taylor Mott on 30-Aug-17.
//  Copyright © 2017 Mott Applications. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    //required
    var coordinate = CLLocationCoordinate2D()
    
    //your defined properties
    var title: String?
    var subtitle: String?
    
}

