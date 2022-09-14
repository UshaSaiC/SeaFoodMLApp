//
//  ViewController.swift
//  SeaFoodApp
//
//  Created by Usha Sai Chintha on 14/09/22.
//

import UIKit
import CoreML
import Vision // it helps in processing images easily and allows us to use images to work with CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
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
                    self.navigationItem.title = "Not Hotdog:("
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

