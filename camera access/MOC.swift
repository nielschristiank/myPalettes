//
//  MOC.swift
//  camera access
//
//  Created by Niels-Christian Kielland on 7/25/17.
//  Copyright © 2017 Anessa Arnold. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ManagedObjectContext: NSManagedObjectContext {

    let MOC = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchAllPalettes(palettes: inout [Palette]) {
        print("fetching...")
        let request: NSFetchRequest<Palette> = Palette.fetchRequest()
        request.returnsObjectsAsFaults = false
        //request.sortDescriptors =
        do{
            print("trying to fetch...")
            let result = try MOC.fetch(request)
            palettes = result
        }catch{
            print("ERROR: \(error)")
        }
    }
    
    func saveColors(colors: [[String:CGFloat]], title: String?, image: UIImage?){
        print("saving...")
        
        let palette = Palette(context: MOC)
        
        palette.paletteTitle = title
        
        let imgData = UIImageJPEGRepresentation(image!, 1)
        palette.setValue(imgData, forKey: "photo")
        
        for color in colors {
            
            let newColor = Color(context: MOC)
            newColor.setValue(Float(color["red"]!), forKey: "red")
            newColor.setValue(Float(color["green"]!), forKey: "green")
            newColor.setValue(Float(color["blue"]!), forKey: "blue")
            
            let addColor = palette.mutableSetValue(forKey: "colors")
            addColor.add(newColor)
        }
        
        do{
            print("trying...")
            try MOC.save()
            print("saved...")
        }catch{
            print("ERROR: \(error)")
        }
        
    }
    
//    func saveColors(colors: [[String:CGFloat]], title: String?){
//        print("saving...")
//        
//        let palette = Palette(context: MOC)
//        palette.paletteTitle = title
//        for color in colors {
//            let newColor = Color(context: MOC)
//            //            newColor.red = Float(color["red"]!)
//            //            newColor.green = Float(color["green"]!)
//            //            newColor.blue = Float(color["blue"]!)
//            //
//            newColor.setValue(Float(color["red"]!), forKey: "red")
//            newColor.setValue(Float(color["green"]!), forKey: "green")
//            newColor.setValue(Float(color["blue"]!), forKey: "blue")
//            
//            let addColor = palette.mutableSetValue(forKey: "colors")
//            addColor.add(newColor)
//        }
//        //palette.paletteTitle = title
//        
//        do{
//            print("trying...")
//            try MOC.save()
//            print("saved...")
//        }catch{
//            print("ERROR: \(error)")
//        }
//    }

    
}
