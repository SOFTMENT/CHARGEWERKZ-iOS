//
//  GooglePlacesManager.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import Foundation
import GooglePlaces

struct Place {
    let name : String?
    let identifier : String?
}
final class GooglePlacesManager {
    
    static let shared = GooglePlacesManager()
    private let client = GMSPlacesClient.shared()
    enum PlacesError : Error {
        case failedToFind
        case failedToFindCoordinates
    }
    private init(){}
    
    public func findPlaces(query : String, completion : @escaping (Result<[Place], Error>) -> Void) {
        let filter = GMSAutocompleteFilter()
    
      
        
        
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
            guard let results = results, error == nil else{
                
              
                completion(.failure(PlacesError.failedToFind))
                return
            }
            
            let places : [Place] = results.compactMap { predication in
                return Place(name: predication.attributedFullText.string, identifier: predication.placeID)
            }
            completion(.success(places))
        }
    }
    
    public func resolveLocation(
        for place : Place,
        completion : @escaping (Result<CLLocationCoordinate2D, Error>) -> Void
    ) {
      
        client.fetchPlace(fromPlaceID: place.identifier!, placeFields: .coordinate, sessionToken: nil) { googlePlace, error in
            
            guard let googlePlace = googlePlace, error == nil else {
              
                completion(.failure(PlacesError.failedToFindCoordinates))
                return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: googlePlace.coordinate.latitude, longitude: googlePlace.coordinate.longitude)
            
            completion(.success(coordinate))
        }
    }
}
