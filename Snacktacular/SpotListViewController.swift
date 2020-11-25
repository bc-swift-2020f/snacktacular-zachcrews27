//
//  SpotListViewController.swift
//  Snacktacular
//
//  Created by Zach Crews on 11/1/20.
//  Copyright © 2020 Zachary Crews. All rights reserved.
//

import UIKit
import CoreLocation

class SpotListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var spots : Spots!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        spots = Spots()
        
        tableView.delegate = self
        tableView.dataSource = self

        configureSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        
        getLocation()
        spots.loadData {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureSegmentedControl() {
        // set font colors for segmented control
        let orangeFontcolor = [NSAttributedString.Key.foregroundColor : UIColor(named: "PrimaryColor") ?? UIColor.orange]
        let whiteFontColor = [NSAttributedString.Key.foregroundColor : UIColor.white]
        sortSegmentedControl.setTitleTextAttributes(orangeFontcolor, for: .selected)
        sortSegmentedControl.setTitleTextAttributes(whiteFontColor, for: .normal)
        // add white border to segmented control
        sortSegmentedControl.layer.borderColor = UIColor.white.cgColor
        sortSegmentedControl.layer.borderWidth = 1.0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! SpotDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.spot = spots.spotArray[selectedIndexPath.row]
        }
    }

    func sortBasedOnSegmentPressed() {
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0: // A-Z
            spots.spotArray.sort(by: {$0.name < $1.name})
        case 1: // closest
            spots.spotArray.sort(by: {$0.location.distance(from: currentLocation) < $1.location.distance(from: currentLocation)})
        case 2: // averageRating
            spots.spotArray.sort(by: {$0.averageRating > $1.averageRating})
        default:
            print("HEY! You shouldn't have gotten here, check out the segmented control")
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
    @IBAction func usersButtonPressed(_ sender: UIBarButtonItem) {
    }
}

extension SpotListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpotTableViewCell
        if let currentLocation = currentLocation {
            cell.currentLocation = currentLocation
        }
        cell.spot = spots.spotArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

extension SpotListViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        // Creating a CLLocationManager will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Checking authentication status")
        handleAuthorizationStatus(status: status)
    }
    
    func handleAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location Services Denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to enable device settings and enable location services for this app.")
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER ALERT: Unknown case of status in handleAuthenticalStatus \(status)")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController  = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("ERROR: Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO: deal with change in location
        
        currentLocation = locations.last ?? CLLocation()
        print("Current location is \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
        sortBasedOnSegmentPressed()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get the device location.")
    }
}
