//
//  NoteListViewController.swift
//  Notetaker-1.0
//
//  Created by Harry Dulaney on 11/26/19.
//  Copyright © 2019 Ben-Logan-Harry. All rights reserved.
//

import CoreData
import UIKit

class NoteTableViewController: UITableViewController {
    
       var notes:[NSManagedObject] = []
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
             loadDataFromDatabase()
             tableView.reloadData()
         }
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }
    
    func loadDataFromDatabase() {
        //Read settings to enable sorting
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField)
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)
        //Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        //Set up Request
        let request = NSFetchRequest<NSManagedObject>(entityName: "Note")
        //Specify sorting
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor]
        //to sort by multiple fields, add more sort descriptors to the array
        request.sortDescriptors = sortDescriptorArray
        
        //Execute request
        do {
            notes = try context.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            
        }
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath)

        // Configure the cell...
        let note = notes[indexPath.row] as? Note
        cell.textLabel?.text = note?.title
        cell.detailTextLabel?.text = note?.subject
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row] as? Note
        let name = selectedNote!.title!
        let actionHandler = { (action:UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "EditNote", sender: tableView.cellForRow(at: indexPath))
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NoteController")
                as? NoteViewController
            controller?.currentNote = selectedNote
            self.navigationController?.pushViewController(controller!, animated: true)
        }
        
        let alertController = UIAlertController(title: "Note selected",
                                                message: "Selected row: \(indexPath.row) (\(name))",
            preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        let actionDetails = UIAlertAction(title: "Show Details",
                                          style: .default,
                                          handler: actionHandler)
        alertController.addAction(actionCancel)
        alertController.addAction(actionDetails)
        present(alertController, animated: true, completion: nil)
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              // Delete the row from the data source
              let contact = notes[indexPath.row] as? Note
              let context = appDelegate.persistentContainer.viewContext
              context.delete(contact!)
              do {
                  try context.save()
              }
              catch {
                  fatalError("Error saving context: \(error)")
              }
              loadDataFromDatabase()
              tableView.deleteRows(at: [indexPath], with: .fade)
          } else if editingStyle == .insert {
              // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
          }
      }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditNote" {
        let noteController = segue.destination as? NoteViewController
        let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
        let selectedNote = notes[selectedRow!] as? Note
        noteController?.currentNote = selectedNote!
            
        }
        
    }
}

