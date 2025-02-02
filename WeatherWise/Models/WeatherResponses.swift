//
//  WeatherResponses.swift
//  GetTheSun
//
//  Created by Aaryan Deshwalon 1/7/25.
//


import Foundation

struct OpenWeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let name: String
    let sys: Sys
}

struct Weather: Codable {
    let main: String
    let description: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
}

struct Sys: Codable {
    let country: String
}

