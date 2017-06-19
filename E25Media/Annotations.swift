//
//  Annotations.swift
//  E25Media
//
//  Created by Amila on 5/23/17.
//  Copyright © 2017 amila. All rights reserved.
//

import Foundation
import MapKit

class Annotations: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title : String, subTitle : String, coordinate : CLLocationCoordinate2D)  {
        
        self.title      = title
        self.subtitle   = subTitle
        self.coordinate = coordinate
        
    }
    
}
