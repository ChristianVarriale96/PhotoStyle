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
    @IBOutlet weak var blockButton: roundButton!
    @IBOutlet weak var picassoButton: roundButton!
    @IBOutlet weak var screamButton: roundButton!
    
    //MARK: - Properties
    var style:Int?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        
        blockButton.isEnabled = false
        picassoButton.isEnabled = false
        screamButton.isEnabled = false
        
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
        switch sender.tag {
        case 0:
            transformImage(style: 1)
        case 1:
            transformImage(style: 2)
        case 2:
            transformImage(style: 3)
        default:
            print("error")
        }
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
        
        // Model Style Transfer Here
        let model = photoStyle()
        
        //Number of styles in the Model and actual style
        let numStyles  = 3
        let styleIndex = style - 1
        
        let styleArray = try? MLMultiArray(shape: [numStyles] as [NSNumber], dataType: .double)
        
        //Deactive all the filters
        //0.0 -> disable | 1.0 -> active
        for i in 0...((styleArray?.count)!-1) {
            styleArray?[i] = 0.0
        }
        
        //Active only the selected
        styleArray?[styleIndex] = 1.0
        
        //Take in input an image that will go in a pixel buffer
        ///this part of code checks if there is an image in imageView and after this we will have a prediction in the pixel buffer that we will convert to UIImage
        if let image = pixelBuffer(from: imageView.image!) {
            do {
                //pass to the model the pixel image and the chosen style, giving like result a styledPhoto that is a prediction
                let predictionOutput = try model.prediction(image: image, index: styleArray!)

                //From pixel to CIImage (Core Image), a representation of an image to be processed or produced by Core Image filters.
                let ciImage = CIImage(cvPixelBuffer: predictionOutput.stylizedImage)
                
                //context for rendering image processing with CIImage
                let tempContext = CIContext(options: nil)
                
                //From CIImage to CGImage with the same dimension
                let tempImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(predictionOutput.stylizedImage), height: CVPixelBufferGetHeight(predictionOutput.stylizedImage)))
                
                //From CGImage to UIImage
                imageView.image = UIImage(cgImage: tempImage!)
                
                //Save Photo to the Album
                UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                
            } catch let error as NSError {
                print("CoreML Model Error: \(error)")
            }
        }
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
            blockButton.isEnabled = true
            screamButton.isEnabled = true
            picassoButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Helper Function: we have to convert an image which the user chooses into some readable data
    //(takes an image and extracts its data by turning it into a pixel buffer which can be read easily by Core ML)
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        
        // 1. we convert the image into a square 256x256.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 256, height: 256), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 256, height: 256))
        _ = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
     
        // 2. from newImage into a CVPixelBuffer that is an image buffer which holds the pixels in the main memory
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, 256, 256, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
           
        // 3. We then take all the pixels present in the image and convert them into a device-dependent RGB color space.
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
           
        // 4. create device space color RGB
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 5. Create the context where render the image
        let context = CGContext(data: pixelData, width: 256, height: 256, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
           
        // 6. render image
        context?.translateBy(x: 0, y: 256)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // 7. Push, modify and pop the context
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: 256, height: 256))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
        // 8. we return our pixel buffer
        return pixelBuffer
    }
}
