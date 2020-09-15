//
//  CurrentLocation.swift
//  fbevents
//
//  Created by User on 07.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import CoreLocation

class CurrentLocation: NSObject, ObservableObject, CLLocationManagerDelegate  {
    private let locationManager = CLLocationManager()
    private var authStatus = CLLocationManager.authorizationStatus()
    @Published var updatingLocation = false
    @Published var locationServiesEnabled = CLLocationManager.locationServicesEnabled()
    internal var lastLocationError: Error?
    @Published var location = CLLocation()

    @Published var placemark: CLPlacemark?

    internal var lastGeocodingError: Error?
    
    func setCoords(coords: Binding<CLLocationCoordinate2D>){
        coords.wrappedValue = location.coordinate
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
    }
    
    internal func updatePlacemark(){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(places, error) in
                if let error = error {self.lastGeocodingError = error}
                self.placemark = places?.last
        })
    }
    internal func startLocationManager() {
        locationServiesEnabled = CLLocationManager.locationServicesEnabled()
        authStatus = CLLocationManager.authorizationStatus()
        if locationServiesEnabled && (authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
        else if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .notDetermined || authStatus == .denied {
                locationManager(locationManager, didFailWithError: CLError(CLError.denied))
            }
        }
        else if authStatus == .denied || authStatus == .restricted {
            locationManager(locationManager, didFailWithError: CLError(CLError.denied))
        }
        else if !locationServiesEnabled {
            locationManager(locationManager, didFailWithError: CLError(CLError.geocodeCanceled))
        }
    }
    internal func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
        }
    }
}
