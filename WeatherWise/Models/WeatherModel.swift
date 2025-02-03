//
//  Weather.swift
//  GetTheSun
//
//  Created by Aaryan Deshwalon 1/6/25.
//

import Foundation

struct WeatherModel: Codable, Identifiable {
    let coordinate: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
    let locationName: String
    let condition: String
    let UV: Double
    let condition2: String
    let icon: String

    
    
    
    
    var isGoodWeather: Bool {
        //return true for testing
        // return true
        
//        production conditons in phase 1
//        return temperature >= 18 && temperature <= 25 &&
//               humidity < 70 &&
//               windSpeed < 20
        
//        production conditons phase 2
//        return main.temp >= 65 && main.temp <= 77 &&
//        main.humidity < 70 &&
//        wind.speed < 12
//
//
        
            let temperatureOK = main.temp > 60
            let windOK = wind.speed < 10
            let cloudsOK = clouds.all < 50
            let uvIndexOK = UV > 3

        let isDaytime = sys.sunrise < Int(Date().timeIntervalSince1970) && sys.sunset > Int(Date().timeIntervalSince1970)

            return temperatureOK && windOK && cloudsOK && uvIndexOK && isDaytime
        }
    }



