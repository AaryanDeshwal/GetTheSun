//
//  Weather.swift
//  GetTheSun
//
//  Created by Aaryan Deshwalon 1/6/25.
//

import Foundation

struct WeatherModel: Codable, Identifiable {
    let id = UUID()
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let locationName: String
    
    var isGoodWeather: Bool {
        //return true for testing
        // return true
        
//        production conditons in phase 1
//        return temperature >= 18 && temperature <= 25 &&
//               humidity < 70 &&
//               windSpeed < 20
        
//        production conditons phase 2
            return temperature >= 65 && temperature <= 77 &&
                   humidity < 70 &&
                   windSpeed < 12
    }
}


