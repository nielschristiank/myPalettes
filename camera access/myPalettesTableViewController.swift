//
//  myPalettesTableViewController.swift
//  camera access
//
//  Created by Niels-Christian Kielland on 7/18/17.
//  Copyright © 2017 Anessa Arnold. All rights reserved.
//

import UIKit
import CoreData


class myPalettesTableViewController: UITableViewController, myPaletteDetailDelegate {
    
    let MOC = ManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    var myPalettes: [[String:CGFloat]]?
    
    var colorObject: [[String:Any?]] = []
    
    var palettes = [Palette]()
    
    var tableText: String?


    @IBOutlet var collectionView: UICollectionView!
    
//    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
//        dismiss(animated: true, completion: nil)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(myPalettes!)
        MOC.fetchAllPalettes(palettes: &palettes)
        //print("My Palettes...\(palettes)")
        for palette in palettes {
            print("Palette...\(palette)")
            for color in palette.colors!.allObjects as! [Color] {
                print("colors...red: \(color.red) green: \(color.green) blue: \(color.blue)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "myPaletteDetailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let destination = navigationController.topViewController as! myPaletteDetailViewController
        destination.delegate = self
        if let ip = sender as? NSIndexPath {
            //let colors = palettes[ip.row].colors!.allObjects as! [Color]
            //destination.colors = colors
            //destination.paletteDetailTitle.text = palettes[ip.row].paletteTitle
            let palette = palettes[ip.row]
            destination.palette = palette
            destination.indexPath = ip
            //destination.delegate = self
        }
    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//        let delete = UITableViewRowAction(style: .destructive, title: "delete") {
//            action, index in
//            print("delete")
//            if indexPath.section == 0 {
//                let palette = self.palettes[indexPath.row]
//                self.MOC.MOC.delete(palette)
//                do{
//                    try self.MOC.MOC.save()
//                }catch{
//                    print("\(error)")
//                }
//            }
//            self.MOC.fetchAllPalettes(palettes: &self.palettes)
//            self.tableView.reloadData()
//        }
//        
//        return [delete]
//    }
    
    func editPalette(by controller: myPaletteDetailViewController, indexPath: NSIndexPath, paletteTitle: String?){
        let palette = self.palettes[indexPath.row]
        palette.paletteTitle = paletteTitle
        do{
            try self.MOC.MOC.save()
        }catch{
            print("\(error)")
        }
        self.MOC.fetchAllPalettes(palettes: &self.palettes)
        self.tableView.reloadData()
    }
    
    func deletePalette(by controller: myPaletteDetailViewController, indexPath: NSIndexPath) {
        let palette = self.palettes[indexPath.row]
        self.MOC.MOC.delete(palette)
        do{
            try self.MOC.MOC.save()
        }catch{
            print("\(error)")
        }
        self.MOC.fetchAllPalettes(palettes: &self.palettes)
        self.tableView.reloadData()
//        dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return myPalettes!.count
        return palettes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPaletteCell", for: indexPath) as! myPalettesTableViewCell
        //self.collectionView.cellForItem(at: indexPath)
        //cell.textLabel?.text = tableText!
        cell.myPaletteTitle.text = palettes[indexPath.row].paletteTitle
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
//        for palette in palettes {
//            let colors = palette.colors!.allObjects as! [Color]
//            cell.myPaletteCollection.numberOfItems(inSection: 1) = colors.count
//            for color in colors {
//                cell.myPaletteCollection.cellForItem(at: indexPath)?.backgroundColor = UIColor(red: CGFloat(color.red / 255.0), green: CGFloat(color.green / 255.0), blue: CGFloat(color.blue / 255.0), alpha: 1.0)
//            }
//        }
        return cell
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}

extension myPalettesTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = palettes[collectionView.tag].colors!.allObjects as! [Color]
        return rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycolorcell", for: indexPath)
        let colors = palettes[collectionView.tag].colors!.allObjects as! [Color]
        let color = colors[indexPath.row]
        cell.backgroundColor = UIColor(red: CGFloat(color.red / 255.0), green: CGFloat(color.green / 255.0), blue: CGFloat(color.blue / 255.0), alpha: 1.0)
        
//        cell.backgroundColor = UIColor(red: (myPalettes![indexPath.row]["red"]! / 255.0), green: (myPalettes![indexPath.row]["green"]! / 255.0), blue: (myPalettes![indexPath.row]["blue"]! / 255.0), alpha: 1)
        
        return cell
    }
}
