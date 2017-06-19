//
//  DetailViewController.swift
//  E25Media
//
//  Created by Amila on 5/30/17.
//  Copyright © 2017 amila. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

protocol LocationsChangedDelegate : class {
    func userChangedLocation (locations : [Location])
}


class DetailViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: LocationsChangedDelegate? = nil
    @IBOutlet weak var table: UITableView!
    var myLocation          : CLLocation!
    var locations           : [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.delegate = self
        self.table.dataSource = self
        
        let fetchRequest : NSFetchRequest<Location>  = Location.fetchRequest()
        do {
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            self.locations = searchResults as [Location]
        }catch{
            print("COreData FetchError")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let location = locations[indexPath.row]
        let cell : DetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as! DetailTableViewCell
        cell.name.text = location.name
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            if let url = NSURL(string: location.img!) {
                if let data = NSData(contentsOf: url as URL) {
                    DispatchQueue.main.async {
                        cell.img.image = UIImage(data: data as Data)
                    }
                }
            }
        }
        
        let tmpLocation = CLLocation(latitude: Double(location.lat!)!, longitude: Double(location.long!)!)
        let kms:CLLocationDistance = myLocation.distance(from: tmpLocation)/1000
        cell.distance.text =  String(format: "%.1f", kms) + " km"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            DatabaseController.getContext().delete(locations[indexPath.row])
            
            self.locations.remove(at: indexPath.row)
            self.table.deleteRows(at: [indexPath], with: .automatic)            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        delegate?.userChangedLocation(locations: self.locations)
    }
}

