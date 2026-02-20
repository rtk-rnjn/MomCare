//
//  LocationManager.swift
//  MomCare+
//
//  Created by Aryan singh on 15/02/26.
//

import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: Lifecycle

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    // MARK: Internal

    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways
        {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        userLocation = locations.first
    }

    // MARK: Private

    private let manager: CLLocationManager = .init()

}
