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
            locationRestriction: GMSPlaceCircularLocationOption(location.coordinate, Constants.searchRadius),
            placeProperties: placeProperties
        )
        
        request.includedTypes = Constants.includedPlaceTypes
    
        client.searchNearby(with: request) { (places, error) in
            guard let results = places, error == nil else {
                print("\(Constants.fetchErrorPrefix)\(error?.localizedDescription ?? Constants.unknownError)")
                completion([])
                return
            }

            let mappedPlaces = results.map { gmsPlace in
                let components = gmsPlace.addressComponents ?? []
                let city = components.first(where: { component in
                    component.types.contains(Constants.localityType)
                        || component.types.contains(Constants.postalTownType)
                        || component.types.contains(Constants.adminAreaLevel1Type)
                })?.name
                let country = components.first(where: { $0.types.contains(Constants.countryType) })?.name

                return Place(
                    id: gmsPlace.placeID ?? Constants.emptyString,
                    name: gmsPlace.name ?? Constants.emptyString,
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

private extension PlacesService {
    enum Constants {
        static let searchRadius: CLLocationDistance = 5000
        static let includedPlaceTypes = ["cafe", "restaurant"]

        static let localityType = "locality"
        static let postalTownType = "postal_town"
        static let adminAreaLevel1Type = "administrative_area_level_1"
        static let countryType = "country"

        static let fetchErrorPrefix = "Error fetching nearby places: "
        static let unknownError = "Unknown error"
        static let emptyString = ""
    }
}
