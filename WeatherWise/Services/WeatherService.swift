//
//  WeatherService.swift
//  GetTheSun
//
//  Created by Aaryan Deshwalon 1/6/25.
//

import Foundation
import CoreLocation

class WeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
   @Published var currentWeather: WeatherModel?
   @Published var locationStatus: LocationStatus = .unknown
   @Published var errorMessage: String?
   
   private let locationManager = CLLocationManager()
   private let apiKey = "48460fe7b8a39ff8396bfc568493212a"
   private var timer: Timer?
   private var isFirstCheck = true // Flag to prevent initial double notification
   
   // Time interval for weather checks (30 minutes = 1800 seconds)
   // Set to 60 seconds for testing
   private let weatherCheckInterval: TimeInterval = 1800
   
   enum LocationStatus {
       case unknown
       case noPermission
       case permissionGranted
       case error
   }
   
   override init() {
       super.init()
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       locationManager.requestWhenInUseAuthorization()
   }
   
   func startPeriodicWeatherChecks() {
       print("Starting periodic weather checks")
       timer?.invalidate()
       isFirstCheck = true
       
       timer = Timer.scheduledTimer(withTimeInterval: weatherCheckInterval, repeats: true) { [weak self] _ in
           print("Weather check timer fired at: \(Date().formatted())")
           self?.locationManager.startUpdatingLocation()
       }
       
       // Initial check
       locationManager.startUpdatingLocation()
   }
   
    
    
    
    
   func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
       //let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
       let UV: Double
       let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"  // Changed to imperial
       guard let url = URL(string: urlString) else {
           throw URLError(.badURL)
       }
       
       let (data, _) = try await URLSession.shared.data(from: url)
       
       //getting UV index
       
       
       let urlStringUV = "https://api.openweathermap.org/data/2.5/uvi?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
       guard let urlUV = URL(string: urlStringUV) else {
           throw URLError(.badURL)
       }
       let (dataUV, _) = try await URLSession.shared.data(from: urlUV)
       
        do {
               let decoder = JSONDecoder()
               let uvIndexResponse = try decoder.decode(UVIndexResponse.self, from: dataUV)
            UV = uvIndexResponse.value
        } catch {
            print("Weather decoding error: \(error)")
            throw error
        }
       //end of getting UV Index
       
       
       
       do {
           let decoder = JSONDecoder()
           let weatherResponse = try decoder.decode(OpenWeatherResponse.self, from: data)
           
           let weatherConditions = weatherResponse.weather.map { $0.description }
           let joinedConditions = weatherConditions.joined(separator: ", ")

               
           return WeatherModel(
            coordinate: weatherResponse.coord,
                weather: weatherResponse.weather,
                base: weatherResponse.base,
                main: weatherResponse.main,
                visibility: weatherResponse.visibility,
                wind: weatherResponse.wind,
                clouds: weatherResponse.clouds,
                dt: weatherResponse.dt,
                sys: weatherResponse.sys,
                timezone: weatherResponse.timezone,
                id: weatherResponse.id,
                name: weatherResponse.name,
                cod: weatherResponse.cod,
                locationName: "\( weatherResponse.name), \(weatherResponse.sys.country)",
                condition: weatherResponse.weather.first?.main ?? "Unknown",
                UV: UV,
                condition2: joinedConditions,
                icon: weatherResponse.weather.first?.icon ?? "Unknown"
           
               
           )
       } catch {
           print("Weather decoding error: \(error)")
           throw error
       }
   }
   
   private func sendWeatherNotification(_ weather: WeatherModel) {
       // Skip notification on first check to avoid double notifications
       guard !isFirstCheck else {
           isFirstCheck = false
           print("📱 Skipping initial notification")
           return
       }
       
//       if weather.isGoodWeather {
//           print("Good weather - Sending notification")
//           NotificationManager.shared.sendNotification(
//               title: "Perfect Weather ☀️",
//               body: """
//               Time to go outside!
//               Temperature: \(Int(weather.temperature))°C
//               Humidity: \(weather.humidity)%
//               Location: \(weather.locationName)
//               Time: \(Date().formatted(date: .omitted, time: .shortened))
//               """
//           )
//       } else {
//           print("Weather conditions not ideal - no notification sent")
//           print("Temperature: \(weather.temperature)°C, Humidity: \(weather.humidity)%, Wind: \(weather.windSpeed) km/h")
//       }
//   }
       if weather.isGoodWeather {
               print("🌤️ Good weather detected! Sending notification")
               NotificationManager.shared.sendNotification(
                   title: "Perfect Weather ☀️",
                   body: """
                   Time to go outside!
                   Temperature: \(Int(weather.main.temp))°F
                   Humidity: \(weather.main.humidity)%
                   Wind: \(String(format: "%.1f", weather.wind.speed)) mph
                   Location: \(weather.locationName)
                   Time: \(Date().formatted(date: .omitted, time: .shortened))
                   """
               )
           } else {
               print("🌥️ Weather conditions not ideal - no notification sent")
               print("Temperature: \(weather.main.temp)°F, Humidity: \(weather.main.humidity)%, Wind: \(weather.wind.speed) mph")
           }
       }
   
   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       DispatchQueue.main.async {
           switch status {
           case .authorizedWhenInUse, .authorizedAlways:
               self.locationStatus = .permissionGranted
               self.locationManager.startUpdatingLocation()
           case .denied, .restricted:
               self.locationStatus = .noPermission
               self.errorMessage = "Please enable location access in Settings to see weather information."
           case .notDetermined:
               self.locationStatus = .unknown
           @unknown default:
               self.locationStatus = .error
           }
       }
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       guard let location = locations.last else { return }
       locationManager.stopUpdatingLocation()
       
       Task {
           do {
               let weather = try await fetchWeather(
                   latitude: location.coordinate.latitude,
                   longitude: location.coordinate.longitude
               )
               DispatchQueue.main.async {
                   self.currentWeather = weather
                   self.sendWeatherNotification(weather)
               }
           } catch {
               DispatchQueue.main.async {
                   self.errorMessage = "Error fetching weather data: \(error.localizedDescription)"
                   self.locationStatus = .error
               }
           }
       }
   }
   
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       DispatchQueue.main.async {
           self.errorMessage = "Location error: \(error.localizedDescription)"
           self.locationStatus = .error
       }
   }
}
