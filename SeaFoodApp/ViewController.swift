//
//  ViewController.swift
//  SeaFoodApp
//
//  Created by Usha Sai Chintha on 14/09/22.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    @IBOutlet weak var wikiLabel: UILabel!
    @IBOutlet weak var cameraImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = true // if we set this value to true, we can edit the image like do croppping and stuff
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{ // if we set image editing value to true, then the InkoKey value should be modified as editedImage instead of originalImage
            self.cameraImageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else{
                fatalError("could not convert to CIImage")
            }
            
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("loading core ml model failed")
        }
        
        let request = VNCoreMLRequest(model: model) {
            request, error in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image ")
            }
            
            if let firstResult = results.first{
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog!"
                }else{
                    self.navigationItem.title = "Not Hotdog:( but its \(firstResult.identifier.capitalized)"
                }
                self.requestInfo(objectName: firstResult.identifier)
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func requestInfo(objectName: String){
        
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts",
        "exintro" : "",
        "explaintext" : "",
        "titles" : objectName,
        "indexpageids" : "",
        "redirects" : "1",
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess{
                print("Got wikipedia info")
                print(response)
                
                let objectJSON: JSON = JSON(response.result.value!)
                let pageID = objectJSON["query"]["pageids"][0].stringValue
                let objectDescription = objectJSON["query"]["pages"][pageID]["extract"].stringValue
                
                self.wikiLabel.text = objectDescription
                
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

