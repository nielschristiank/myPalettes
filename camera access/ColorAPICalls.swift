//
//  ColorAPICalls.swift
//  camera access
//
//  Created by Niels-Christian Kielland on 7/27/17.
//  Copyright © 2017 Anessa Arnold. All rights reserved.
//

import Foundation
import UIKit

class ColorAPICalls {
    
    static func getFromAPI(url: String, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        let url = URL(string: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!, completionHandler: completionHandler)
        
        task.resume()
    }
}
