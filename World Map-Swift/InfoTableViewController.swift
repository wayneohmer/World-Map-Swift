//
//  InformationTableTableViewController.swift
//  World Map
//
//  Created by Wayne Ohmer on 6/16/15.
//  Copyright (c) 2015 Wayne Ohmer. All rights reserved.
//

import UIKit

internal class InfoTableViewController: UITableViewController {

    var infoArray:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) as! InfoTableViewCell

        cell.infoCellLabel.text = self.infoArray[indexPath.row]

        return cell
    }

}

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var infoCellLabel: UILabel!
    
}


