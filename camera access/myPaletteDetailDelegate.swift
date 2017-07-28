//
//  myPaletteDetailDelegate.swift
//  camera access
//
//  Created by Niels-Christian Kielland on 7/26/17.
//  Copyright © 2017 Anessa Arnold. All rights reserved.
//

import UIKit

protocol myPaletteDetailDelegate {
    func deletePalette(by controller: myPaletteDetailViewController, indexPath: NSIndexPath)
    func editPalette(by controller: myPaletteDetailViewController, indexPath: NSIndexPath, paletteTitle: String?)
}
