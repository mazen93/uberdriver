//
//  DriverVC.swift
//  uberdriver
//
//  Created by mac on 8/5/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController ,CLLocationManagerDelegate,MKMapViewDelegate,UberController{
 
    
    
   
    
   
    @IBOutlet weak var cancelUberBtn: UIButton!
    
    
    
    @IBOutlet weak var MyMap: MKMapView!
    private var locationManager=CLLocationManager()
    private var userLocation:CLLocationCoordinate2D?
    
    
    
    // update location
    private var riderLocation:CLLocationCoordinate2D?
    private var timer = Timer()
    
    
    private var acceptedUber=false
    private var driverCanceledUber=false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initializationLocationManager()
        
        
        UberHandler.Instance.delegate=self
        UberHandler.Instance.observeMessageForDriver()
    }
    
    
    func updateRidersLocation(lat: Double, lng: Double) {
        riderLocation=CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    

    
    private func initializationLocationManager(){
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if have coordate
        if let location = locationManager.location?.coordinate{
            userLocation=CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        let region=MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            
            MyMap.setRegion(region, animated: true)
            
            let allAnnotations = self.MyMap.annotations
            self.MyMap.removeAnnotations(allAnnotations)
            
            
            
            
            if riderLocation != nil{
                if acceptedUber {
                    let annotation=MKPointAnnotation()
                    annotation.coordinate=riderLocation!
                    annotation.title="Rider"
                    MyMap.addAnnotation(annotation)
                }
            }
            let annotation=MKPointAnnotation()
            annotation.coordinate=userLocation!
            annotation.title="Driver"
            MyMap.addAnnotation(annotation)
        
        
        }
    }
    
    
    
    func acceptUber(lat: Double, lng: Double) {
        
        
        
        if !acceptedUber{
            UberRequest(title: "Uber Request", message: "you have request from lat : \(lat),lng : \(lng)", requestAlive: true)

        }
        
        
    }
    
    
    func riderCanceledUber() {
        if !driverCanceledUber{
            //cancel uber from driver
            
            UberHandler.Instance.cancelUberforDriver()
            self.acceptedUber=false
            self.cancelUberBtn.isHidden=true
            
            UberRequest(title: "Uber Canceld", message: "uber cancel order mother fucker", requestAlive: false)
        }
    }
    
    
    
    
    @IBAction func CancelUberButton(_ sender: Any) {
        if acceptedUber{
            cancelUberBtn.isHidden=true
            driverCanceledUber=true
            cancelUberBtn.isHidden=true
            UberHandler.Instance.cancelUberforDriver()
            
            // invalidate timer
             timer.invalidate()
            
         
            
        }
        
     
    }
    
    
    
    // update location
    
    @objc func updateDriversLocation()  {
        UberHandler.Instance.updateDriverLocation(lat: (userLocation?.latitude)!, lng: (userLocation?.longitude)!)
    }
    
    
    func uberCancel() {
        acceptedUber=false
        cancelUberBtn.isHidden=true
        //invalidate timer
        timer.invalidate()
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        if AuthProvider.Instance.logOut(){
           // dismiss(animated: true, completion: nil)
            
            if acceptedUber{
                cancelUberBtn.isHidden=true
                UberHandler.Instance.cancelUberforDriver()
                timer.invalidate()
            }
            
            dismiss(animated: true, completion: nil)
            
            
        }else{
            // could not log out
            
            
            UberRequest(title: "could not logout", message: "please try again ", requestAlive: false)
            
        }
    }
    
    
    func UberRequest(title:String,message:String,requestAlive:Bool)  {
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)

        if requestAlive {
            
            let accept=UIAlertAction(title: "Accept", style: .default) { (alertAction) in
                // accept
                self.acceptedUber=true
                self.cancelUberBtn.isHidden=false
                
                // repeat call func to update
                self.timer=Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DriverVC.updateDriversLocation), userInfo: nil, repeats: true)
                
                
                
                
                
                
                // inform that accepted uber
                UberHandler.Instance.uberAccepted(lat: Double(self.userLocation!.latitude), lng: Double(self.userLocation!.longitude))
                
                
            }
            let cancel=UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            
            alert.addAction(accept)
            alert.addAction(cancel)
            
            
        }else{
             let ok=UIAlertAction(title: "ok", style: .default, handler: nil)
             alert.addAction(ok)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    private func alert(title:String,message:String){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok=UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
