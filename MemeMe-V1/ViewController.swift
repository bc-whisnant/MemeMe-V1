//
//  ViewController.swift
//  MemeMe-V1
//
//  Created by Galvatron on 1/1/18.
//  Copyright © 2018 Galvatron. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    //declare variables here
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var memedImage: UIImage?
    
    
    //added text attributes for text fields
    //added code for the text field styles
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: 4]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //set default attributes for text fields and assign delegates to each
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        //this sets the code to center align ---> this has to be done via code
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if the device doesn't have a camera this will make sure the source type is disabled.
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
        
        if (pickedImageView.image != nil) {
            // enable the share button only when this condition is met
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //added functionality for photo album
    @IBAction func libraryButtonPressed(_ sender: Any) {
        //image picker view
        let pickerController = UIImagePickerController()
        //sets delefate for picker view
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    //added functionaltiy for camera
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //added ability to share photo
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // this generates a memed image
        memedImage = generateMemedImage()
        
        //create activity view controller
        let activityViewController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        
        // present the activity view controller
        present(activityViewController, animated: true, completion: nil)
        
        //save meme and then dismiss view since action is complete ---> remember the proper syntax for completionWithItemsHandler
        //this part was really difficult to code
        activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                self.save() // save the meme
                activityViewController.dismiss(animated: true, completion: nil)
            } else {
                print("error saving the meme image")
            }
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //sets background of imageview as long as the chosen item is a UI Image
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //the following functions are a solution for the keyboard covering the bottom input field
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
    }

    //this code actually creates the meme ---> remember the struct in MemeStruct.swift!!
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!,
                        originalImage: pickedImageView.image!, memedImage: memedImage)
    }
    //this renders the view to an actual image
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        navigationController?.toolbar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        
        return memedImage
    }

    //this function allows the return button to dismiss the keyboard
    func textFieldShouldReturn(_ topTextField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //the following code makes sure the share button is enabled unless an image is selected
//    func enableShareOnlyIfConditionsAreMet() {
//        if (pickedImageView.image != nil) {
//            // enable the share button only when this condition is met
//            shareButton.isEnabled = true
//        } else {
//            shareButton.isEnabled = false
//        }
//    }
    
    


}

