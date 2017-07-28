//
//  myPalettesTableViewCell.swift
//  camera access
//
//  Created by Niels-Christian Kielland on 7/26/17.
//  Copyright © 2017 Anessa Arnold. All rights reserved.
//

import UIKit

class myPalettesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var myPaletteTitle: UILabel!
    
    
    var colors = [Color]()
    
    @IBOutlet weak var myPaletteCollection: UICollectionView!
    
}

extension myPalettesTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int){
        
        myPaletteCollection.delegate = dataSourceDelegate
        myPaletteCollection.dataSource = dataSourceDelegate
        myPaletteCollection.tag = row
        myPaletteCollection.reloadData()
    }
}

