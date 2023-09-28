//
//  weatherData.swift
//  Clima
//
//  Created by Samarah Anderson on 4/30/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation


//more than one protocol can be combined under a single name - codable combines the encodable and decodable protocols 
struct WeatherData: Codable {
    var name = "String"
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int //making this constant so that it's able to pull the id data from the api
}
