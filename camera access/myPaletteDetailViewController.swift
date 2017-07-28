//
//  myPaletteDetailViewController.swift
//  camera access
//
//  Created by Niels-Christian Kielland on 7/26/17.
//  Copyright © 2017 Anessa Arnold. All rights reserved.
//

import UIKit

class myPaletteDetailViewController: UIViewController {
    
    @IBOutlet weak var paletteDetailTitle: UITextField!
    
    @IBOutlet weak var paletteDetailCollection: UICollectionView!
    
    @IBOutlet weak var colorInfoLabel: UILabel!
    
    @IBOutlet weak var rgbCmykLabel: UILabel!
    
    @IBOutlet weak var colorLoading: UIActivityIndicatorView!
    var delegate: myPaletteDetailDelegate?
    
    var indexPath: NSIndexPath?
    
    var colors: [Color] =  [Color]()
    var colorNames: [String] = [String]()
    var colorNamesDict: [Int: String] = [Int: String]()
    
    var palette: Palette?
    var finished: Bool?
    
    //var currentTask: URLsession?

    @IBOutlet weak var detailImageView: UIImageView!
    
    var detailPhoto: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(myPaletteDetailViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myPaletteDetailViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //self.finished = true
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(myPaletteDetailViewController.imageTapped(_:)))
        detailImageView.addGestureRecognizer(pictureTap)
        detailImageView.isUserInteractionEnabled = true
        self.colorLoading.isHidden = true
        self.rgbCmykLabel.isHidden = true
        self.hideKeyboardWhenTappedAround()
        colors = []
        colorNames = []
        paletteDetailCollection.delegate = self
        paletteDetailCollection.dataSource = self
        self.title = palette?.paletteTitle
        paletteDetailTitle.text = palette?.paletteTitle
        if let paletteData = palette {
            if let colorData = paletteData.colors?.allObjects {
                if let colorArr = colorData as? [Color] {
                    colors = colorArr
                }
            }
        }
        //colors = palette!.colors!.allObjects as! [Color]
        if let imageData = palette?.value(forKey: "photo") as? NSData {
            if let image = UIImage(data: imageData as Data) {
                detailImageView.image = image
            }
        }
        //print(colors)
        //let firstColor = "\(Int(colors[0].red)),\(Int(colors[0].green)),\(Int(colors[0].blue))"
//        for i in 0..<colors.count {
//            let colorData = colors[i]
//            let color = "\(Int(colorData.red)),\(Int(colorData.green)),\(Int(colorData.blue))"
//            //if self.finished == true {
//            print("requesting...color...\(color) \(i)")
//            self.apiColorRequest(url: "http://thecolorapi.com/id?rgb=\(color)", count: 0, idx: i)
//        }
        //self.apiColorRequest(url: "http://thecolorapi.com/id?rgb=\(firstColor)")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //ColorAPICalls.URLsession.cancel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        print(imageView.image?.imageOrientation)
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.fixedCoordinateSpace.bounds
        newImageView.backgroundColor = .black
        if newImageView.image?.imageOrientation != .up {
           // newImageView.contentMode = .scaleAspectFit
        }
        else{
            newImageView.contentMode = .scaleAspectFit
        }
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
   
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.delegate?.editPalette(by: self, indexPath: self.indexPath!, paletteTitle: self.paletteDetailTitle.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete Confirmation", message: "Are you sure you want to delete this palette, there is no turning back!!!!!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.delegate?.deletePalette(by: self, indexPath: self.indexPath!)
            self.dismiss(animated: true, completion: nil)
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func apiColorRequest(url: String, count: Int, idx: Int?){
        //self.finished = false
        
        ColorAPICalls.getFromAPI(url: url, completionHandler: {
            data, response, error in
            print(response)
            if let resData = data {
                do{
                    print("trying..")
                    if let jsonResult = try JSONSerialization.jsonObject(with: resData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    //print(response)
                    
                        if let result = jsonResult["name"] {
                            if let name = result as? NSDictionary {
                                print(name["value"])
                            //self.finished = true
                                if let value = name["value"] as? String {
                                    self.colorNames.append(value)
                                    if let i = idx {
                                        self.colorNamesDict[i] = value
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    print("Error: \(error)")
                }
            }
            else{
                var counter = count
                counter += 1
                print(counter)
                if counter < 4 {
                    self.apiColorRequest(url:url, count: counter, idx: idx)
                }
            }
        })
    }
    
    func apiSingleColorRequest(url: String, indexPath: IndexPath) {
        ColorAPICalls.getFromAPI(url: url, completionHandler: {
          data, response, error in
            print(response)
            if let resData = data {
                do{
                    print("trying..")
                    if let jsonResult = try JSONSerialization.jsonObject(with: resData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        print("done trying...")
                        
                        if let result = jsonResult as? NSDictionary { //jsonResult["name"] as? NSDictionary {
                            print("result...\(result)")
                            if let name = result["name"] as? NSDictionary {
                                print("name...\(name)")
                                //self.finished = true
                                if let value = name["value"] as? String {
                                    //self.colorNames.append(value)
                                    if let cmykData = result["cmyk"] as? NSDictionary {
                                        if let cmyk = cmykData["value"] as? String {
                                            DispatchQueue.main.async{
                                                let color = self.colors[indexPath.row]
                                                self.colorInfoLabel.text = "\(value)"
                                                self.rgbCmykLabel.text = "rgb(\(Int(color.red)), \(Int(color.green)), \(Int(color.blue))) \n \(cmyk)"
                                                self.rgbCmykLabel.isHidden = false
                                                self.colorLoading.isHidden = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    print("Error: \(error)")
                }
            }
            else{
//                let color = self.colors[indexPath.row]
//                self.colorInfoLabel.text = "rgb(\(Int(color.red)),\(Int(color.green)),\(Int(color.blue)))"
            }
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

}

extension myPaletteDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paletteDetailCell", for: indexPath) as! myPaletteDetailCollectionCell
        let color = colors[indexPath.row]
        cell.selectedLbel.text = ""
        cell.backgroundColor = UIColor(red: CGFloat((color.red / 255.0)), green: CGFloat((color.green / 255.0)), blue: CGFloat((color.blue / 255.0)), alpha: 1)
        //cell.name.text = "rgb(\(Int(color.red)),\(Int(color.green)),\(Int(color.blue)))"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.reloadData()
        let color = colors[indexPath.row]
        self.colorInfoLabel.text = ""
        self.rgbCmykLabel.isHidden = true
        self.colorLoading.isHidden = false
//        if indexPath.row < colorNames.count {
//            if let name = colorNames[indexPath.row] as? String {
//                self.colorInfoLabel.text = name
//            }
//        }
//        if let name = self.colorNamesDict[indexPath.row] as? String {
//            self.colorInfoLabel.text = name
//        }
//        else{
//            self.colorInfoLabel.text = "rgb(\(Int(color.red)),\(Int(color.green)),\(Int(color.blue)))"
//        }
        self.colorInfoLabel.textColor = UIColor(red: CGFloat((color.red / 255.0)), green: CGFloat((color.green / 255.0)), blue: CGFloat((color.blue / 255.0)), alpha: 1)
        let colorToGet = "\(Int(color.red)),\(Int(color.green)),\(Int(color.blue))"
        self.apiSingleColorRequest(url: "http://thecolorapi.com/id?rgb=\(colorToGet)", indexPath: indexPath)
        self.colorInfoLabel.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        self.colorInfoLabel.layer.shadowOpacity = 2.0
        self.colorInfoLabel.layer.shadowRadius = 2.0
        let cell = collectionView.cellForItem(at: indexPath) as? myPaletteDetailCollectionCell
        
        cell?.layer.borderWidth = 4.0
        cell?.layer.borderColor = UIColor.blue.cgColor
        //cell?.selectedLbel.text = "☑️"
        //collectionView.cellForItem(at: indexPath)?.isHighlighted = true
        //collectionView.cellForItem(at: indexPath)?.isSelected = true
        //collectionView.cellForItem(at: indexPath)
        //collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? myPaletteDetailCollectionCell
        cell?.layer.borderWidth = 0
    }
    
    //selectitem
}
