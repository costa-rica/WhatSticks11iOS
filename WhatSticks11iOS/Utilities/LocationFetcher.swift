//
//  LocationFetcher.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 08/01/2024.
//

import Foundation
import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D(){
        didSet{
            print("userLocation.lat: \(userLocation.latitude)")
            print("userLocation.lon: \(userLocation.longitude)")
        }
    }

    override init() {
        print("- LocationFetcher init()")
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func fetchLocation() {
        print("- LocationFetcher fetchLocation()")
        locationManager.requestLocation() // Request location once
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("- LocationFetcher locationManager()")
//        userLocation = locations.first?.coordinate
        if let unwp_locations = locations.first {
            userLocation = unwp_locations.coordinate
            // You might want to stop updating location here or handle it as per your requirement
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
    }
}


