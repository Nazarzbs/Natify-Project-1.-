//
//  MainViewController.swift
//  Natify-Project-1
//
//  Created by Nazar on 17.02.2026.
//


import UIKit
import GoogleMaps
import CoreLocation

final class MainViewController: UIViewController, GMSMapViewDelegate {

    private var places: [Place] = []
    private var currentLocation: CLLocation?
    private var didFetchNearby = false

    private let mapView: GMSMapView = {
        let mapView = GMSMapView()
        mapView.camera = GMSCameraPosition(
            latitude: Constants.defaultMapLatitude,
            longitude: Constants.defaultMapLongitude,
            zoom: Constants.defaultMapZoom
        )
        mapView.backgroundColor = .systemGray6
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private var searchRadiusCircle: GMSCircle?
    
    private let centerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBackground
        button.tintColor = .systemBlue
        button.layer.cornerRadius = Constants.centerButtonCornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = Constants.centerButtonShadowOpacity
        button.layer.shadowOffset = CGSize(width: 0, height: Constants.centerButtonShadowOffsetY)
        button.layer.shadowRadius = Constants.centerButtonShadowRadius
        button.setImage(UIImage(systemName: Constants.centerButtonImageName), for: .normal)
        return button
    }()
    
    private let locationService = LocationService()
    
    private let placesService = PlacesService()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupViews()
        bindLocation()
        locationService.request()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

private extension MainViewController {
    func setupViews() {
        mapView.delegate = self
        centerButton.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)

        view.addSubview(mapView)
        view.addSubview(centerButton)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            centerButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Constants.centerButtonTrailingInset
            ),
            centerButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.centerButtonBottomInset
            ),
            centerButton.widthAnchor.constraint(equalToConstant: Constants.centerButtonSize),
            centerButton.heightAnchor.constraint(equalToConstant: Constants.centerButtonSize)
        ])
    }

    
    func bindLocation() {
        locationService.onLocationUpdate = { [weak self] location in
            DispatchQueue.main.async {
                guard let self else { return }
                self.currentLocation = location
                self.centerMap(on: location)
                self.fetchNearbyPlacesIfNeeded(for: location)
            }
        }
    }
    
    func centerMap(on location: CLLocation) {
        let camera = GMSCameraPosition(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: Constants.userLocationZoom
        )
        mapView.animate(to: camera)
        updateSearchRadiusCircle(at: location.coordinate)
    }

    func updateSearchRadiusCircle(at coordinate: CLLocationCoordinate2D) {
        searchRadiusCircle?.map = nil

        let circle = GMSCircle(position: coordinate, radius: Constants.searchRadius)
        circle.fillColor = UIColor.systemBlue.withAlphaComponent(Constants.searchCircleFillOpacity)
        circle.strokeColor = UIColor.systemBlue.withAlphaComponent(Constants.searchCircleStrokeOpacity)
        circle.strokeWidth = Constants.searchCircleStrokeWidth
        circle.map = mapView

        searchRadiusCircle = circle
    }

    @objc
    func centerOnUserLocation() {
        guard let location = currentLocation else { return }
        centerMap(on: location)
    }

    func fetchNearbyPlacesIfNeeded(for location: CLLocation) {
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

    func renderPlaceMarkers() {
        mapView.clear()

        for place in places {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude
            )
            marker.title = "\(place.name), \(place.country ?? "")"
            marker.snippet = "\(place.city ?? ""), \(place.address ?? "")"
            marker.map = mapView
        }

        if let coordinate = currentLocation?.coordinate {
            updateSearchRadiusCircle(at: coordinate)
        }
    }
}

private extension MainViewController {
    enum Constants {
        static let defaultMapLatitude: CLLocationDegrees = 46.4825
        static let defaultMapLongitude: CLLocationDegrees = 30.7233
        static let defaultMapZoom: Float = 10

        static let userLocationZoom: Float = 14
        static let searchRadius: CLLocationDistance = 5000

        static let searchCircleFillOpacity: CGFloat = 0.1
        static let searchCircleStrokeOpacity: CGFloat = 0.35
        static let searchCircleStrokeWidth: CGFloat = 2

        static let centerButtonImageName = "location.fill"
        static let centerButtonSize: CGFloat = 48
        static let centerButtonCornerRadius: CGFloat = 24
        static let centerButtonTrailingInset: CGFloat = 16
        static let centerButtonBottomInset: CGFloat = 24
        static let centerButtonShadowOpacity: Float = 0.18
        static let centerButtonShadowOffsetY: CGFloat = 2
        static let centerButtonShadowRadius: CGFloat = 4
    }
}
