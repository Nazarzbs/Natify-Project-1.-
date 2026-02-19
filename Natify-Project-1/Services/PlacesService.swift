//
//  PlacesService.swift
//  Natify-Project-1
//
//  Created by Nazar on 18.02.2026.
//


import GooglePlaces
import CoreLocation

final class PlacesService {

    private let client = GMSPlacesClient.shared()

    func fetchNearby(
        location: CLLocation,
        completion: @escaping ([Place]) -> Void
    ) {
        let placeProperties: [String] = [
            GMSPlaceProperty.name.rawValue,
            GMSPlaceProperty.placeID.rawValue,
            GMSPlaceProperty.coordinate.rawValue,
            GMSPlaceProperty.formattedAddress.rawValue,
            GMSPlaceProperty.addressComponents.rawValue,
            GMSPlaceProperty.types.rawValue
        ]

        let request = GMSPlaceSearchNearbyRequest(
            locationRestriction: GMSPlaceCircularLocationOption(location.coordinate, 5000),
            placeProperties: placeProperties
        )
        
        request.includedTypes = ["cafe", "restaurant"]
    
        client.searchNearby(with: request) { (places, error) in
            guard let results = places, error == nil else {
                print("Error fetching nearby places: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let mappedPlaces = results.map { gmsPlace in
                let components = gmsPlace.addressComponents ?? []
                let city = components.first(where: { component in
                    component.types.contains("locality")
                        || component.types.contains("postal_town")
                        || component.types.contains("administrative_area_level_1")
                })?.name
                let country = components.first(where: { $0.types.contains("country") })?.name

                return Place(
                    id: gmsPlace.placeID ?? "",
                    name: gmsPlace.name ?? "",
                    address: gmsPlace.formattedAddress,
                    city: city,
                    country: country,
                    coordinate: Coordinate(
                        latitude: gmsPlace.coordinate.latitude,
                        longitude: gmsPlace.coordinate.longitude
                    ),
                    types: gmsPlace.types ?? []
                )
            }

            completion(mappedPlaces)
        }
    }
}
