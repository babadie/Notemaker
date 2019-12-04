//
//  NewNoteViewController.swift
//  Notetaker-1.0
//
//  Created by Harry Dulaney on 11/26/19.
//  Copyright © 2019 Ben-Logan-Harry. All rights reserved.
//

import UIKit
import CoreData


class NoteViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var sgmtPriority: UISegmentedControl!
    @IBOutlet weak var btnSave: UIButton!
    
    var currentNote: Note?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeEditMode(self)
        
        if (currentNote != nil) {
            txtTitle.text = currentNote!.title
            txtSubject.text = currentNote!.subject
            txtNote.text = currentNote!.noteText
            /*
             switch currentNote!.priority {
             case "High":
                 sgtPrio.selectedSegmentIndex = 0
             case "Medium":
                 sgtPrio.selectedSegmentIndex = 1
             case "Low":
                 sgtPrio.selectedSegmentIndex = 2
             default:
                 print("I don't know what i'm doing lol")
             }*/
        }
        txtNote.delegate = self
        // Do any additional setup after loading the view.
        
        txtTitle.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)),
                            for: UIControl.Event.editingDidEnd)
        
        //txtNote.addTarget(self, action: #selector(UITextViewDelegate.textViewShouldEndEditing(_:)), for: UIControl.Event.editingDidEnd)

        //sgtPrio.addTarget(self, action: #selector(NotesViewController.indexChanged(_:)), for: .valueChanged)

    }
    
    func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtTitle, txtSubject]
        let textViews: [UITextView] = [txtNote]
        
        for textField in textFields {
            textField.isEnabled = true
            
        }
        txtNote.isEditable = true
        //sgtPrio.isEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveNote))
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        currentNote?.title = txtTitle.text
        currentNote?.subject = txtSubject.text
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        currentNote?.noteText = txtNote.text
        if txtNote.text.isEmpty {
            txtNote.text = " "
        }
        else {
            currentNote?.noteText = txtNote.text
        }
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
    
    @objc func saveNote() {
           if currentNote == nil {
            let noteTitle = txtTitle.text
            let noteSubject = txtSubject.text
            let noteDetails = txtNote.text
            if let moc = managedObjectContext {
                let note = Note(context: moc)
                
                note.title = noteTitle
                note.subject = noteSubject
                note.noteText = noteDetails
                
                saveToCoreData() {
                    let isPresentingInaddFluidPatientMode = self.presentingViewController is UINavigationController
                    if isPresentingInaddFluidPatientMode {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.navigationController!.popViewController(animated: true)
                    }
                }
            }
       }
        
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
        
        func saveToCoreData(completion: @escaping() -> Void) {
            managedObjectContext!.perform {
                do {
                    try self.managedObjectContext?.save()
                    completion()
                    print("Note Saved")
                }
                catch let error {
                    print("Note not saved")
                }
            }
        }
}
