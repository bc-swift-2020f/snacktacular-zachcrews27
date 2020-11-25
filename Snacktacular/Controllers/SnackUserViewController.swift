//
//  SnackUserViewController.swift
//  Snacktacular
//
//  Created by Zach Crews on 11/25/20.
//  Copyright © 2020 Zachary Crews. All rights reserved.
//

import UIKit

class SnackUserViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var snackUsers: SnackUsers!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        snackUsers = SnackUsers()
        snackUsers.loadData {
            self.tableView.reloadData()
        }

    }
}

extension SnackUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snackUsers.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SnackUserTableViewCell
        cell.snackUser = snackUsers.userArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
