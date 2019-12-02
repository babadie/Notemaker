//
//  NewNoteViewController.swift
//  Notetaker-1.0
//
//  Created by Harry Dulaney on 11/26/19.
//  Copyright © 2019 Ben-Logan-Harry. All rights reserved.
//

import UIKit
import CoreData


class NoteViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    var currentNote: Note?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func dateChanged(date: Date) {
        if currentContact != nil {
            currentContact?.birthday = date as NSDate? as Date?
            appDelegate.saveContext()
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            lblBirthdate.text = formatter.string(from: date)
        }
    }
   
   
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnChange: UIButton!

 
    
    @IBOutlet weak var imgContactPicture: UIImageView!
   
    
    @IBAction func changePicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraController = UIImagePickerController()
            cameraController.sourceType = .camera
            cameraController.cameraCaptureMode = .photo
            cameraController.delegate = self
            cameraController.allowsEditing = true
            self.present(cameraController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imgContactPicture.contentMode = .scaleAspectFit
            imgContactPicture.image = image
            
            if currentNote == nil {
                let context =
                    appDelegate.persistentContainer.viewContext
                currentNote = Note(context: context)
            }
            currentNote?.image=NSData(data:
                image.jpegData(compressionQuality: 1.0)!) as Data
        }
        dismiss(animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
  /*
        if currentContact != nil {
               txtName.text = currentContact!.contactName
               txtAddress.text = currentContact!.streetAddress
               txtCity.text = currentContact!.city
               txtState.text = currentContact!.state
               txtZip.text = currentContact!.zipcode
               txtPhone.text = currentContact!.phoneNumber
               txtCell.text = currentContact!.cellNumber
               txtEmail.text = currentContact!.email
               let formatter = DateFormatter()
               formatter.dateStyle = .short
               if currentContact!.birthday != nil {
                lblBirthdate.text = formatter.string(from: currentContact!.birthday!)
                   
               }
            if let imageData = currentContact?.image as? Data{
            imgContactPicture.image = UIImage(data: imageData)
            }
           }
        
           changeEditMode(self)
           
           let textFields: [UITextField] = [txtName, txtAddress, txtCity, txtState, txtZip,
           txtPhone, txtCell, txtEmail] */

        for textField in textFields {
            textField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)),
                                for: UIControl.Event.editingDidEnd)
        }
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      /*  currentContact?.contactName = txtName.text
        currentContact?.streetAddress = txtAddress.text
        currentContact?.city = txtCity.text
        currentContact?.state = txtState.text
        currentContact?.zipcode = txtZip.text
        currentContact?.cellNumber = txtCell.text
        currentContact?.phoneNumber = txtPhone.text
        currentContact?.email = txtEmail.text
        return true*/
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
               super.viewWillAppear(animated)
               self.registerKeyboardNotifications()
           }
           
           override func viewWillDisappear(_ animated: Bool) {
               super.viewWillDisappear(animated)
               self.unregisterKeyboardNotifications()
           }
    
    @objc func saveContact() {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact(context: context)
        }
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
        }
    
     func registerKeyboardNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        func unregisterKeyboardNotifications() {
            NotificationCenter.default.removeObserver(self)
        }

    @objc func keyboardDidShow(notification: NSNotification) {
            let userInfo: NSDictionary = notification.userInfo! as NSDictionary
            let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
            let keyboardSize = keyboardInfo.cgRectValue.size
            
            //Get the existing contentInset for the scrollView and set the bottom property to be the height of the keyboard
            var contentInset = self.scrollView.contentInset
            contentInset.bottom = keyboardSize.height
            
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
        }
        
        @objc func keyboardWillHide(notification: NSNotification) {
            var contentInset = self.scrollView.contentInset
            contentInset.bottom = 0
            
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueContactDate") {
        let dateController = segue.destination as! DateViewController
        dateController.delegate = self
        }
        }
    }
