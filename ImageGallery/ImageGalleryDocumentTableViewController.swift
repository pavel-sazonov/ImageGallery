//
//  ImageGalleryDocumentTableViewController.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 08/05/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class ImageGalleryDocumentTableViewController: UITableViewController {
     override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // show master on start in all multitasking modes
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // test images
            galleries[0][0].imageAttributes.urls = [
                URL(string: "http://www.rspcasa.org.au/wp-content/uploads/2019/01/Adopt-a-cat-or-kitten-from-RSPCA.jpg")!,
                URL(string: "https://img.washingtonpost.com/wp-apps/imrs.php?src=https://img.washingtonpost.com/rf/image_960w/2010-2019/WashingtonPost/2016/05/05/Interactivity/Images/iStock_000001440835_Large1462483441.jpg&w=1484")!,
                URL(string: "http://www.rspcasa.org.au/wp-content/uploads/2019/01/Adopt-a-cat-or-kitten-from-RSPCA.jpg")!,
                URL(string: "https://img.washingtonpost.com/wp-apps/imrs.php?src=https://img.washingtonpost.com/rf/image_960w/2010-2019/WashingtonPost/2016/05/05/Interactivity/Images/iStock_000001440835_Large1462483441.jpg&w=1484")!,
                URL(string: "http://www.rspcasa.org.au/wp-content/uploads/2019/01/Adopt-a-cat-or-kitten-from-RSPCA.jpg")!,
                URL(string: "https://img.washingtonpost.com/wp-apps/imrs.php?src=https://img.washingtonpost.com/rf/image_960w/2010-2019/WashingtonPost/2016/05/05/Interactivity/Images/iStock_000001440835_Large1462483441.jpg&w=1484")!,
                URL(string: "http://www.rspcasa.org.au/wp-content/uploads/2019/01/Adopt-a-cat-or-kitten-from-RSPCA.jpg")!,
                URL(string: "https://img.washingtonpost.com/wp-apps/imrs.php?src=https://img.washingtonpost.com/rf/image_960w/2010-2019/WashingtonPost/2016/05/05/Interactivity/Images/iStock_000001440835_Large1462483441.jpg&w=1484")!,
                URL(string: "https://www.nydailynews.com/resizer/x8DqQ_WT3uE0QyS0fe2C527xIZI=/1200x0/arc-anglerfish-arc2-prod-tronc.s3.amazonaws.com/public/AU6GU3ZVA5G2NBT2CUTD2K53C4.jpg")!,
                URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT6IT5rN3bmo6lhbrZDh5Pdu19OoM8uFtRvk6LzrTZP22uLf2kc")!,
                URL(string: "https://dcist.com/wp-content/uploads/sites/3/2019/04/Gem2-1500x1346.jpg")!,
                URL(string: "https://img.washingtonpost.com/wp-apps/imrs.php?src=https://img.washingtonpost.com/rf/image_960w/2010-2019/WashingtonPost/2016/05/05/Interactivity/Images/iStock_000001440835_Large1462483441.jpg&w=1484")!,
        ]
        
        galleries[0][0].imageAttributes.aspectRatios = [
            1.2763819095477387,
            0.6690909090909091,
            1.2763819095477387,
            0.6690909090909091,
            1.2763819095477387,
            0.6690909090909091,
            1.2763819095477387,
            0.6690909090909091,
            1.0,
            0.9955555555555555,
            0.8987341772151899,
            0.6690909090909091,
        ]
    }
    
    // MARK: - Model
    
    var galleries = [[ImageGallery(name: "Gallery one")], [ImageGallery]()]
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return galleries.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        
        return galleries[section].isEmpty ? nil : "Recently Deleted"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DocumentCell",
            for: indexPath) as! TextFieldTableViewCell
        
        cell.imageGallery = galleries[indexPath.section][indexPath.row]
        
        cell.resignationHandler = { [weak self, unowned cell] in
            if let text = cell.textField.text {
                self?.galleries[indexPath.section][indexPath.row].name = text
            }
            
            tableView.reloadRows(at: [indexPath], with: .fade)
            self?.selectRowAndSegue(at: indexPath)
        }
        
        return cell
    }
    
    // MARK: - Select row
    var lastSelectedRow = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // select first row in main section
        selectRowAndSegue(at: IndexPath(row: lastSelectedRow, section: 0))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        performSegue(withIdentifier: "Show Gallery", sender: indexPath)
    }
    
    private func selectRowAndSegue(at indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        tableView(tableView, didSelectRowAt: indexPath)
    }
    
    // MARK: - Delete row.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                // move row to 'recently deleted' section
                tableView.performBatchUpdates({
                    let deletedGallery = galleries[0].remove(at: indexPath.row)
                    galleries[1].append(deletedGallery)
                    tableView.moveRow(at: indexPath, to: IndexPath(row: galleries[1].count-1, section: 1))
                }, completion: { [unowned self] finished in
                    tableView.reloadRows(at: [IndexPath(row: self.galleries[1].count-1, section: 1)], with: .fade)
                    
                    Timer.scheduledTimer(withTimeInterval: 1.1, repeats: false) { timer in
                        tableView.selectRow(at: IndexPath(row: self.galleries[1].count-1, section: 1), animated: false, scrollPosition: .none)
                    }
                })
            } else if indexPath.section == 1 {
                tableView.performBatchUpdates({
                    galleries[1].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                })
            }
        }
    }
    
    // MARK: - Add row
    
    @IBAction func newImageGallery(_ sender: UIBarButtonItem) {
        tableView.performBatchUpdates({
            let newGallery = ImageGallery(name: ImageGallery.uniqNewGalleryName(for: galleries))
            galleries[0].append(newGallery)
            tableView.insertRows(at: [IndexPath(row: galleries[0].count - 1, section: 0)], with: .fade)
        }) { [unowned self] finished in
            self.selectRowAndSegue(at: IndexPath(row: self.galleries[0].count - 1, section: 0))
        }
    }
    
    // MARK: - Leading swipe for restore row from recently deleted section
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return nil }
        
        let restoreAction = UIContextualAction(style: .normal, title: "Restore") { (action, view, handler) in
            // move row to section 0
            tableView.performBatchUpdates({
                let deletedGallery = self.galleries[1].remove(at: indexPath.row)
                self.galleries[0].append(deletedGallery)
                tableView.moveRow(at: indexPath, to: IndexPath(row: self.galleries[0].count-1, section: 0))
            }, completion: { [unowned self] finished in
                tableView.reloadRows(at: [IndexPath(row: self.galleries[0].count-1, section: 0)], with: .fade)
                
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
                    self.selectRowAndSegue(at: IndexPath(row: self.galleries[0].count-1, section: 0))
                }
            })
            handler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [restoreAction])
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath,
            let imageGallery = segue.destination.contents as? ImageGalleryCollectionViewController {
                imageGallery.imageAttributes = galleries[indexPath.section][indexPath.row].imageAttributes
                imageGallery.title = galleries[indexPath.section][indexPath.row].name
                lastSelectedRow = indexPath.row
        }
    }
    
    // don't segue from Recently Deleted
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            indexPath.section == 1 { return false }
        return true
    }

}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
