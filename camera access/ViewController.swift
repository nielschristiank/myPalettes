//
//  ViewController.swift
//  camera access
//
//  Created by Anessa Arnold on 7/18/17.
//  Copyright © 2017 Anessa Arnold. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Parse
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let MOC = ManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    @IBOutlet weak var colorsLoading: UIActivityIndicatorView!
    
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared

    @IBOutlet weak var launchImage: UIImageView!
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var savePaletteButton: UIButton!
    
    @IBOutlet weak var titleInputView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var paletteTitle: UILabel!
    @IBOutlet weak var paletteTitleTextField: UITextField!
    
    var colors: [[String:CGFloat]] = []
    
    var isCamera: Bool?
    
    var googleAPIKey = "YOUR_API_KEY"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.launchImage.image = UIImage(named: "cover")
       // self.navigationItem.rightBarButtonItem = nil
        self.colorsLoading.isHidden = true
        self.collectionView.isHidden = true
        self.savePaletteButton.isHidden = true
        self.paletteTitle.isHidden = true
        self.paletteTitleTextField.isHidden = true
        self.titleInputView.isHidden = true
        colors = []
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        //collectionView.collectionViewLayout.
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraButton(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            isCamera = true
            //self.collectionView.isHidden = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

//    @IBAction func cameraButton(_ sender: UIBarButtonItem) {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
//            imagePicker.allowsEditing = false
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//        
//    }
 
    @IBAction func openPhotoLibraryButton(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = true
        isCamera = false
        //self.collectionView.isHidden = true
        self.present(imagePicker, animated: true, completion: nil)
        
        }
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
//        let imageData = UIImageJPEGRepresentation(pickedImage.image!, 0.6)
//        let compressedJPEGImage = UIImage(data: imageData!)
//        UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
//        DispatchQueue.main.async{self.saveNotice()}
        //MOC.saveColors(colors: colors, title: paletteTitleTextField.text)
        performSegue(withIdentifier: "myPaletteSegue", sender: sender)
    }
    
    @IBAction func savePaletteButtonPressed(_ sender: UIButton) {
        let imageData = UIImageJPEGRepresentation(pickedImage.image!, 0.6)
        let compressedJPEGImage = UIImage(data: imageData!)
        if isCamera == true {
            UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
        }
        MOC.saveColors(colors: colors, title: paletteTitleTextField.text, image: pickedImage.image)
        performSegue(withIdentifier: "myPaletteSegue", sender: sender)
        
        //clear view
        self.savePaletteButton.isHidden = true
        self.paletteTitle.isHidden = true
        self.paletteTitleTextField.isHidden = true
        self.paletteTitleTextField.text = ""
        self.titleInputView.isHidden = true
        self.pickedImage.isHidden = true
        self.collectionView.isHidden = true
        self.launchImage.isHidden = false

    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]!) {
        self.colors = []
        pickedImage.image = image
        let binaryImageData = base64EncodeImage(image)
        createRequest(with: binaryImageData)
        self.dismiss(animated: true, completion: nil);
        //self.navigationItem.rightBarButtonItem = self.saveButton
        //self.savePaletteButton.isHidden = false
        self.launchImage.isHidden = true
        self.paletteTitle.isHidden = false
        self.paletteTitleTextField.isHidden = false
        self.paletteTitleTextField.text = ""
        self.titleInputView.isHidden = false
        self.pickedImage.isHidden = false
        self.collectionView.isHidden = true
        self.colorsLoading.isHidden = false
        }
    
    func saveNotice(){
        let alertController = UIAlertController(title: "Image saved!", message: "Your picture was succesfully saved", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        //performSegue(withIdentifier: "myPaletteSegue", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //if segue.identifier == "myPaletteSegue" {
        let colors = self.colors  //as? [[String:CGFloat]]
        let navigationController = segue.destination as! UINavigationController
        //let destination = segue.destination as! myPalettesTableViewController
        //myPaletteController.delegate = self
        //}
        let destination = navigationController.topViewController as! myPalettesTableViewController
        destination.myPalettes = colors
        destination.tableText = "New Palette"
    }
}


extension ViewController {
    
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            //self.collectionView.isHidden = true
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                //self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                //print(json)
                let responses: JSON = json["responses"][0]
                
                //Get image properties
                let imagePropertiesAnnotation = responses["imagePropertiesAnnotation"]
                //print("imageproperties \(imagePropertiesAnnotation)")
                if imagePropertiesAnnotation != JSON.null {
                    let colors = imagePropertiesAnnotation["dominantColors"]["colors"]
                    //print("array of colors \(colors)")
                    for i in 0..<colors.count {
                        let RGB = colors[i]["color"]
                        let red = RGB["red"].floatValue
                        let green = RGB["green"].floatValue
                        let blue = RGB["blue"].floatValue
                        //print("R: \(red) G: \(green) B: \(blue)")
                        //self.labelResults.backgroundColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
                        //self.view.backgroundColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
                        self.colors.append(["red": CGFloat(red), "green": CGFloat(green), "blue":CGFloat(blue)])
                    }
                    self.collectionView.isHidden = false
                    self.colorsLoading.isHidden = true
                    self.collectionView.reloadData()
                    //print(self.colors)
                    self.savePaletteButton.isHidden = false
                }
            }
        })
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//           // imageView.contentMode = .scaleAspectFit
//            //imageView.isHidden = true // You could optionally display the image here by setting imageView.image = pickedImage
//           // spinner.startAnimating()
//            //faceResults.isHidden = true
//            //labelResults.isHidden = true
//            
//            // Base64 encode the image and create the request
//            let binaryImageData = base64EncodeImage(pickedImage)
//            createRequest(with: binaryImageData)
//        }
//        
//        dismiss(animated: true, completion: nil)
//    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

extension ViewController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "IMAGE_PROPERTIES",
                        "maxResults": 10
                    ],
                    //                    [
                    //                        "type": "FACE_DETECTION",
                    //                        "maxResults": 10
                    //                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
        cell.backgroundColor = UIColor(red: (colors[indexPath.row]["red"]! / 255.0), green: (colors[indexPath.row]["green"]! / 255.0), blue: (colors[indexPath.row]["blue"]! / 255.0), alpha: 1)
        
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: 102, height: 100);
//    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    // Compute the dimension of a cell for an NxN layout with space S between
//    // cells.  Take the collection view's width, subtract (N-1)*S points for
//    // the spaces between the cells, and then divide by N to find the final
//    // dimension for the cell's width and height.
//    
//    let cellsAcross: CGFloat = 3
//    let spaceBetweenCells: CGFloat = 1
//    let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
//    return CGSize(width: dim, height: dim)
//    }
}

extension UICollectionViewFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 120.0, height: 100.0);
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}




