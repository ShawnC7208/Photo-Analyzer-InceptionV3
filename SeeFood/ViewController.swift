//
//  ViewController.swift
//  SeeFood
//
//  Created by Shawn Chandwani on 7/16/20.
//  Copyright © 2020 Shawn Chandwani. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not conver to CIImage")
            }
            detect(image: ciImage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        do {
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("could not process result of VNClassificationObservation")
                }
                if let firstResult = results.first {
                    self.navigationItem.title = firstResult.identifier
                }
//                let topClassifications = results.prefix(1).map {
//                  (confidence: $0.confidence, identifier: $0.identifier)
//                }
                //print(topClassifications)
            }
            let handler = VNImageRequestHandler(ciImage: image)
            
            try handler.perform([request])
            
        } catch {
            print(error)
        }
    }
    
}
