//
//  MainViewController.swift
//  Natify-Project-1
//
//  Created by Nazar on 17.02.2026.
//


import UIKit
import GoogleMaps
import CoreLocation

class MainViewController: UIViewController, GMSMapViewDelegate {

    private var places: [Place] = []
    private var currentLocation: CLLocation?

    private var mapView: GMSMapView!
    private let locationService = LocationService()

    private var loadingDismissWorkItem: DispatchWorkItem?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        view.layoutIfNeeded() 
        setupMap()
        bindLocation()
        locationService.request()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupMap() {
        mapView = GMSMapView()
        mapView.frame = view.bounds
        mapView.camera = GMSCameraPosition(latitude: 46.4825, longitude: 30.7233, zoom: 10)
        mapView.backgroundColor = .systemGray6
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    
    private func bindLocation() {
        locationService.onLocationUpdate = { [weak self] location in
            DispatchQueue.main.async {
                self?.centerMap(on: location)
            }
        }
    }
    
    private func centerMap(on location: CLLocation) {
        let camera = GMSCameraPosition(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 14
        )
        mapView.animate(to: camera)
    }
}
