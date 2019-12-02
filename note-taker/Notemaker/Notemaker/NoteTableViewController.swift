//
//  NoteListViewController.swift
//  Notetaker-1.0
//
//  Created by Harry Dulaney on 11/26/19.
//  Copyright © 2019 Ben-Logan-Harry. All rights reserved.
//

import CoreData
import UIKit

class ContactsTableViewController: UITableViewController {
    
       var notes:[NSManagedObject] = []
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
      
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
   
    }
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
              // Pass the selected object to the new view controller.
                      if segue.identifier == "EditNote" {
                        let contactController = segue.destination as? NoteViewController
                          let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
                          let selectedContact = notes[selectedRow!] as? Note
                          contactController?.currentContact = selectedContact!
                      }
                    }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
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
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath)

        // Configure the cell...
        let contact = notes[indexPath.row] as? Note
        cell.textLabel?.text = contact?.contactName
        cell.detailTextLabel?.text = contact?.city
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = notes[indexPath.row] as? Note
        let name = selectedContact!.contactName!
        let actionHandler = { (action:UIAlertAction!) -> Void in
            //            self.performSegue(withIdentifier: "EditContact", sender: tableView.cellForRow(at: indexPath))
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NoteController")
                as? NoteViewController
            controller?.currentContact = selectedContact
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation



}

