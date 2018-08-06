//
//  UberHandler.swift
//  uberdriver
//
//  Created by mac on 8/6/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import Firebase


protocol UberController:class {
    func acceptUber(lat:Double,lng:Double)
    func riderCanceledUber()
    func uberCancel()
    
    func updateRidersLocation(lat:Double,lng:Double)
}


class UberHandler {
    
    private static let _instance=UberHandler()
    
    weak var delegate:UberController?
    var rider=""
    var driver=""
    var driver_id=""
    
    
    static var Instance:UberHandler{
        return _instance
    }
    
    
    // request uber
//    func requestUber(latitude:Double,longitude:Double)  {
//        let data:Dictionary<String,Any>=[Constants.NAME:rider,Constants.LATITUDE:latitude,Constants.LONGITUDE:longitude]
//
//        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
//
//
//    }
    
    
    
    func observeMessageForDriver()  {
        // Rider Request Uber
        
        
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
         
            
            
            if let data=snapshot.value   as? NSDictionary{
                if let latitude=data[Constants.LATITUDE] as? Double{
                    if let longitude=data[Constants.LONGITUDE] as? Double{
                        // inform driver vc
                        
                        
                        self.delegate?.acceptUber(lat: latitude, lng: longitude)
                    }
                }
                
                
                if let name=data[Constants.NAME] as? String {
                    self.rider=name
                }
                
                
                
            }
        }
        
        
        
        // Rider updating location
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot) in
            if  let data = snapshot.value as? NSDictionary {
                
                if let lat=data[Constants.LATITUDE] as? Double{
                    if let lng=data[Constants.LONGITUDE] as? Double{
                   
                        self.delegate?.updateRidersLocation(lat: lat, lng: lng)
                    }
                }
            }
        }
        
        
        
            // Rider Cancel Uber
            
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
                
                if  let data = snapshot.value as? NSDictionary {
                    if let name=data[Constants.NAME] as? String{
                        if name==self.rider{
                           self.rider=""
                            self.delegate?.riderCanceledUber()
                            
                        }
                    }
                }
                
            }
            
       // Rider Accept uber
        
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
            
            if  let data = snapshot.value as? NSDictionary {
                if let name=data[Constants.NAME] as? String{
                    if name==self.driver{
                        self.driver_id=snapshot.key
                       
                        
                    }
                }
            }
            
        }
        
        // Driver Cancel uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            
            if  let data = snapshot.value as? NSDictionary {
                if let name=data[Constants.NAME] as? String{
                    if name==self.driver{
                        self.delegate?.uberCancel()
                        
                        
                    }
                }
            }
            
        }
        
        
        
    }
    
    
    func uberAccepted(lat:Double,lng:Double)  {
        
        
        let data:Dictionary<String,Any>=[Constants.NAME:driver,Constants.LATITUDE:lat,Constants.LONGITUDE:lng]
   
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    
    
    }
    
    
    func cancelUberforDriver()  {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue()
    }
    // update
    func updateDriverLocation(lat:Double,lng:Double)  {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE:lat,Constants.LONGITUDE:lng])
    }
}
