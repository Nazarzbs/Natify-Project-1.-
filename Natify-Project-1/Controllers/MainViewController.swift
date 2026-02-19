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
    private var didFetchNearby = false

    private var mapView: GMSMapView!
    private var searchRadiusCircle: GMSCircle?
    private let centerButton = UIButton(type: .system)
    private let locationService = LocationService()
    private let placesService = PlacesService()

    private var loadingDismissWorkItem: DispatchWorkItem?
    private var locationFallbackWorkItem: DispatchWorkItem?
    private let fallbackLocation = CLLocation(latitude: 46.4825, longitude: 30.7233)

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
        setupCenterButton()
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

    private func setupCenterButton() {
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        centerButton.backgroundColor = .systemBackground
        centerButton.tintColor = .systemBlue
        centerButton.layer.cornerRadius = 24
        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOpacity = 0.18
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        centerButton.layer.shadowRadius = 4
        centerButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        centerButton.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)

        view.addSubview(centerButton)
        NSLayoutConstraint.activate([
            centerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            centerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            centerButton.widthAnchor.constraint(equalToConstant: 48),
            centerButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    
    private func bindLocation() {
        locationService.onLocationUpdate = { [weak self] location in
            DispatchQueue.main.async {
                guard let self else { return }
                self.currentLocation = location
                self.locationFallbackWorkItem?.cancel()
                self.centerMap(on: location)
                self.fetchNearbyPlacesIfNeeded(for: location)
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
        updateSearchRadiusCircle(at: location.coordinate)
    }

    private func updateSearchRadiusCircle(at coordinate: CLLocationCoordinate2D) {
        searchRadiusCircle?.map = nil

        let circle = GMSCircle(position: coordinate, radius: 5000)
        circle.fillColor = UIColor.systemBlue.withAlphaComponent(0.1)
        circle.strokeColor = UIColor.systemBlue.withAlphaComponent(0.35)
        circle.strokeWidth = 2
        circle.map = mapView

        searchRadiusCircle = circle
    }

    @objc
    private func centerOnUserLocation() {
        guard let location = currentLocation else { return }
        centerMap(on: location)
    }

    private func fetchNearbyPlacesIfNeeded(for location: CLLocation) {
        guard !didFetchNearby else { return }
        didFetchNearby = true
    
        placesService.fetchNearby(location: location) { [weak self] places in
            DispatchQueue.main.async {
                guard let self else { return }
                self.places = places
            
                self.renderPlaceMarkers()
            }
        }
    }

    private func renderPlaceMarkers() {
        mapView.clear()

        for place in places {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude
            )
            marker.map = mapView
        }

        if let coordinate = currentLocation?.coordinate {
            updateSearchRadiusCircle(at: coordinate)
        }
    }
}
