//
//  NewNoteViewController.swift
//  Notetaker-1.0
//
//  Created by Harry Dulaney on 11/26/19.
//  Copyright © 2019 Ben-Logan-Harry. All rights reserved.
//

import UIKit
import CoreData


class NoteViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var currentNote: Note?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate


    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var sgmtPriority: UISegmentedControl!
    @IBOutlet weak var btnSave: UIButton!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeEditMode(self)
        let textFields: [UITextField] = [txtTitle, txtSubject]
        let textViews: [UITextView] = [txtNote]
        //self.txtNote.delegate = self as! UITextViewDelegate
        if currentNote == nil {
            txtTitle.text == nil
            txtSubject.text == nil
            txtNote.text = nil
        }
        for textfield in textFields {
            textfield.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControl.Event.editingDidEnd)
        }
         if currentNote != nil {
            txtTitle.text = currentNote!.title
            txtSubject.text = currentNote!.subject
            txtNote.text = currentNote!.noteText

        }
        

    }
    
    func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtTitle, txtSubject]
        let textViews: [UITextView] = [txtNote]
        for textView in textViews {
            textView.isEditable = true
        }
        for textField in textFields {
            textField.isEnabled = true
            textField.borderStyle = UITextField.BorderStyle.roundedRect
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveNote))
    }
    
    @objc func saveNote() {
        if currentNote == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentNote = Note(context: context)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        currentNote?.title = txtTitle.text
        currentNote?.subject = txtSubject.text
        currentNote?.noteText = txtNote.text
        return true
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
        
        // Get the existing contentInset for the scrollView and set the bottom property to be the height of the keyboard
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

    
    func openSettings(){
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }

    }
