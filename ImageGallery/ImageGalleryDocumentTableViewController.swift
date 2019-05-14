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
    
    var galleries = [[ImageGallery](), [ImageGallery]()]
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return galleries.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        
        let label = UILabel()
        label.text = "Recently Deleted"
        label.backgroundColor = UIColor.lightGray
        return label
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        let galleryName = galleries[indexPath.section][indexPath.row].name

        cell.textLabel?.text = galleryName

        return cell
    }

    // Delete row.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                let deletedGallery = galleries[0].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // insert deleted row in 'recently deleted' section
                galleries[1].append(deletedGallery)
                tableView.insertRows(at: [IndexPath(row: galleries[1].count - 1, section: 1)],
                                     with: .fade)
            } else if indexPath.section == 1 {
                galleries[1].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // MARK: - Create New Gallery
    
    @IBAction func newImageGallery(_ sender: UIBarButtonItem) {
        let newGallery = ImageGallery(name: ImageGallery.uniqNewGalleryName(for: galleries))
        galleries[0].append(newGallery)
        tableView.reloadData()
    }
    
    // MARK: - Leading swipe for restore row from recently deleted section
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return nil }
        
        let restoreAction = UIContextualAction(style: .normal, title: "Restore") { (action, view, handler) in
            let deletedGAllery = self.galleries[1].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // insert deleted row in section 0
            let insertIndexPath = IndexPath(row: self.galleries[0].endIndex, section: 0)
            self.galleries[0].insert(deletedGAllery, at: self.galleries[0].endIndex)
            tableView.insertRows(at: [insertIndexPath], with: .fade)
            handler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [restoreAction])
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageGallery = segue.destination as? ImageGalleryCollectionViewController {
            imageGallery.title = (sender as? UITableViewCell)?.textLabel?.text
        }
    }

}
