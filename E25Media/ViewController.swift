import MapKit
import CoreLocation
import UIKit
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, LocationsChangedDelegate {
    
    @IBOutlet var mapView   : MKMapView!
    var locationManager     : CLLocationManager!
    var myLocation          : CLLocation!
    var isMapLoaded         : Bool = false
    var locationList : [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (isMapLoaded == false){
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            else if CLLocationManager.authorizationStatus() == .denied {
                
                let alert = UIAlertController(title: "OOPS", message: "Location services were previously denied. Please enable location services for this app in Settings.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.myLocation = locations.last as CLLocation!
        
        if let location = locations.first {
            
            if (self.isMapLoaded == false){
                
                let regionRadius: CLLocationDistance = 100000
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 3.0, regionRadius * 3.0)
                mapView.setRegion(coordinateRegion, animated: true)
                self.isMapLoaded = true
                locationManager.stopUpdatingLocation()
                
                let fetchRequest : NSFetchRequest<Location>  = Location.fetchRequest()
                do {
                    let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
                    
                    if (searchResults.count > 0){
                        addAnnotations(locations: searchResults)
                    }else{
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).sync {
                            self.getdata()
                        }
                    }
                }catch{
                    print("COreData FetchError")
                }
            }
        }
    }
    
    func getdata(){
        
        let endpoint    : String = "http://35.164.199.21/api/get_cities"
        let url         : NSURL  = NSURL(string: endpoint)!
        let session     = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue("825iosDev", forHTTPHeaderField: "api-key")
        
        session.dataTask(with: request as URLRequest, completionHandler:{ (data, response, error) -> Void in
            
            if (response != nil){
                let realresponse = response as? HTTPURLResponse
                
                DispatchQueue.main.async {
                    if (realresponse!.statusCode == 200){
                        do{
                            if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String:Any] {
                                print(json)
                                let recived_locations = json["cities"] as! [[String : AnyObject]]
                                
                                for location in recived_locations {
                                    
                                    let locationRecived : Location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: DatabaseController.getContext()) as! Location
                                    
                                    locationRecived.name    = location["name"]! as? String
                                    locationRecived.img     = location["imageUrl"]! as? String
                                    locationRecived.long    = "\(location["coordinates"]!["longitude"] as! NSNumber)"
                                    locationRecived.lat     = "\(location["coordinates"]!["latitude"] as! NSNumber)"
                                    DatabaseController.saveContext()
                                    
                                    self.locationList.append(locationRecived)
                                    
                                }
                                self.dismiss(animated: false, completion: nil)
                                self.addAnnotations(locations: self.locationList)
                            }
                        }catch {
                            print("Error with Json: \(error)")
                        }
                    }
                    else{
                        print("Http Error")
                    }
                }
            }
        }).resume()
        DispatchQueue.main.async {
            self.showLoading()
        }
    }
    
    func showLoading (){
        
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func userChangedLocation(locations: [Location]) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.addAnnotations(locations: locations)
        
    }
    
    func addAnnotations(locations: [Location]) -> Void {
        
        for item in locations {
            let coordinate = CLLocationCoordinate2D(latitude: Double(item.lat!)!, longitude: Double(item.long!)!)
            let pin = Annotations(title: item.name! , subTitle: "", coordinate: coordinate)
            mapView.addAnnotation(pin)
        }
        
    }
    
    @IBAction func goNext(_ sender: Any) {
        
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let vc          = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.myLocation   = self.myLocation
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
}
