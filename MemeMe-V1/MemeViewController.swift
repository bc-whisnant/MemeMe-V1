//
//  MemeViewController.swift
//  MemeMe-V1
//
//  Created by Galvatron on 1/1/18.
//  Copyright © 2018 Galvatron. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    //declare variables here
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var btmToolBar: UIToolbar!
    
    var memedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configure(textField: topTextField, withText: "TOP")
        configure(textField: bottomTextField, withText: "BOTTOM")

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if the device doesn't have a camera this will make sure the source type is disabled.
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
        //disables share button until an image is selected to prevent premature sharing of meme
        //changed this so all items are not nil when the share button is pressed
        if (pickedImageView.image != nil && bottomTextField.text != nil && topTextField != nil) {
            // enable the share button only when this condition is met
            shareButton.isEnabled = true
        } else {
            //if any items are nil the share button won't be enabled
            shareButton.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //added functionality for photo album
    @IBAction func libraryButtonPressed(_ sender: Any) {
        presentImagePickerWith(sourceType: .photoLibrary)
    }
    
    //added functionaltiy for camera
    @IBAction func cameraButtonPressed(_ sender: Any) {
        presentImagePickerWith(sourceType: .camera)
    }
    
    //added ability to share photo
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // this generates a memed image
        memedImage = generateMemedImage()
        
        //create activity view controller
        let activityViewController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        
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
        
        // present the activity view controller
        present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    //add ability to cancel here
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        // Reset to blank image and default text in textfields
        pickedImageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        dismiss(animated: true, completion: nil)
        //if cancel button is pressed then the share button is once again disabled until all items are nil
        shareButton.isEnabled = false
    }
    
    //added function to set defaults for text fields
    func configure(textField: UITextField, withText text: String){
        // set delegate, text, default attributes, etc...
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -4]
        textField.defaultTextAttributes = memeTextAttributes
        //this sets the code to center align ---> this has to be done via code
        textField.textAlignment = .center
        textField.delegate = self
        //added capitilazation
        textField.autocapitalizationType = .allCharacters
        
    }
    
    //added function to configure and present image picket --- source type changes depending on library or camera button pressed
    
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
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
        //view only moves up if bottom text field is pressed
        if bottomTextField.isFirstResponder {
             view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
       
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
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }

    //this renders the view to an actual image
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        configureBars(hidden: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        configureBars(hidden: false)
        
        return memedImage
    }
    
    //this code actually creates the meme ---> remember the struct in MemeStruct.swift!!
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!,
                        originalImage: pickedImageView.image!, memedImage: memedImage)
    }

    //this function allows the return button to dismiss the keyboard
    func textFieldShouldReturn(_ topTextField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    //added function to hide toolbars depending on bool value
    func configureBars(hidden: Bool) {
        topToolBar.isHidden = hidden
        btmToolBar.isHidden = hidden
        
    }

}

