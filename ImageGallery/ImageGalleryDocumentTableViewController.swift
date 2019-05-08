//
//  ImageGalleryDocumentTableViewController.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 08/05/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class ImageGalleryDocumentTableViewController: UITableViewController {
    
    // MARK: - Model
    
    var galleries = [
        ["one", "two", "three"],
        ["lol", "pol", "bol"]
    ]
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return galleries.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = UIColor.lightGray
        
        label.text = section == 0 ? "Galleries" : "Recently deleted"
        
        return label
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        let galleryName = galleries[indexPath.section][indexPath.row]

        cell.textLabel?.text = galleryName

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            galleries[0].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Create New Gallery
    
    @IBAction func newImageGallery(_ sender: UIBarButtonItem) {
        galleries[0] += ["Untitled".madeUnique(withRespectTo: galleries[0])]
        tableView.reloadData()
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    func madeUnique(withRespectTo otherStrings: [String]) -> String {
        var possiblyUnique = self
        var uniqueNumber = 1
        while otherStrings.contains(possiblyUnique) {
            possiblyUnique = self + " \(uniqueNumber)"
            uniqueNumber += 1
        }
        return possiblyUnique
    }
}
