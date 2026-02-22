//
//  Place.swift
//  Natify-Project-1
//
//  Created by Nazar on 17.02.2026.
//


import Foundation

struct Place {
    let id: String
    let name: String
    let address: String?
    let city: String?
    let country: String?
    let coordinate: Coordinate
    let types: [String]
    let rating: Double?
    
    var displayInfo: String {
        var info = [name]
        
        if let city = city, !city.isEmpty {
            info.append(city)
        }
        
        if let country = country, !country.isEmpty {
            info.append(country)
        }
        
        if let address = address, !address.isEmpty {
            info.append(address)
        }
        
        return info.joined(separator: ", ")
    }
}

struct Coordinate {
    let latitude: Double
    let longitude: Double
}
