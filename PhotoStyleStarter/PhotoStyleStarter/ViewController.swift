//
//  ViewController.swift
//  PhotoStyle
//
//  Created by Christian Varriale on 27/03/2020.
//  Copyright © 2020 Christian Varriale. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Properties
    var style:Int?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2941176471, green: 0.3960784314, blue: 0.5176470588, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(cgColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))]
        
        view.backgroundColor = #colorLiteral(red: 0.915378511, green: 0.931581676, blue: 0.9433452487, alpha: 1)
        
    }
    
    //MARK: - IBAction
    @IBAction func pickImageButtonPressed(_ sender: Any) {
        
        //Defining the Tipology of alert, that we want to present to the users
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Defining Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            DispatchQueue.main.async {
                self.presentImagePicker(withType: .camera)
            }
        }
        
        //Defining Gallery Action
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            DispatchQueue.main.async {
                self.presentImagePicker(withType: .photoLibrary)
            }
        }
        
        //Defining Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //Add Action to the Controller
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        //Show View
        present(actionSheet, animated: true, completion: nil)
    }
    
    //In according to the button pressed, thanks to the sender.tag, it can be possible to apply the effect
    @IBAction func buttonPressed(_ sender: UIButton) {

    }
    
    // MARK: Private Methods
    private func presentImagePicker(withType type: UIImagePickerController.SourceType) {
        //Definiton of imagePickerController with Delegate, sourceType and Present
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true)
    }
    
    //MARK: - @objc Function
    @objc func transformImage(style: Int) {

    }
    
    //Alert displayed when you have applied the effect
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        } else {
            
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        }
    }

    //the delegate take the media that you have choose in the picker and pass it to the variable
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Helper Function: we have to convert an image which the user chooses into some readable data
    //(takes an image and extracts its data by turning it into a pixel buffer which can be read easily by Core ML)
//    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
//
//    }
}
