//
//  WeatherDisplay.swift
//  GetTheSun
//
//  Created by Aaryan Deshwalon 1/6/25.
//

import SwiftUI

struct WeatherDisplay: View {
    let weather: WeatherModel
    @State private var timeRemaining: Int
    let timerInterval: Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Initialize with different intervals for testing/production
    init(weather: WeatherModel, isTestMode: Bool = true) {
        self.weather = weather
        // Set interval: 30 seconds for testing, 30 minutes for production
        self.timerInterval = isTestMode ? 30 : 1800
        // Initialize timeRemaining with the interval
        _timeRemaining = State(initialValue: isTestMode ? 30 : 1800)
    }
    
    var formattedTimeRemaining: String {
        if timerInterval <= 60 {
            // For test mode: show seconds only
            return "\(timeRemaining)s"
        } else {
            // For production: show minutes and seconds
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Weather")
                .font(.largeTitle)
                .bold()
            
            Text(weather.locationName)
                .font(.title2)
                .foregroundColor(.gray)
            
            HStack {
               
                Image(systemName: getWeatherIcon(condition: weather.condition2))
                                   .font(.system(size: 60))
                    .font(.system(size: 60))
//                Text("\(Int(weather.temperature))°C")
                Text("\(Int(weather.main.temp))°F")
                    .font(.system(size: 50))
                    
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                        Text("")
                    }
                
                WeatherInfoRow(icon: "humidity", label: "Humidity", value: "\(weather.main.humidity)%")
            //WeatherInfoRow(icon: "wind", label: "Wind Speed", value: "\(String(format: "%.1f", weather.windSpeed)) km/h")
                WeatherInfoRow(icon: "wind", label: "Wind Speed", value: "\(String(format: "%.1f", weather.wind.speed)) mph")
                WeatherInfoRow(icon: "cloud", label: "Cloud ", value: "\(weather.clouds.all)%")
                    
            }
            VStack {
                if weather.isGoodWeather {
                    Image(systemName: "sun")
                   Text("Weather condition is good")
                        
                    Spacer()
                    Text("Enjoy Outside")
                        .bold()
                        
                } else {
                    HStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                        Text("weather condition might not be suitable,")
                        Spacer()
                        Text("Relax inside")
                            .bold()
                        
                    }
                    .frame(height: 50)
                }
            }
            
//            HStack {
//                Text("By: Aaryan Deshwal")
//                    .font(.system(size: 10)) // This sets the font size to 10 points
//                Spacer() // This pushes the owner name to the right
//                Text("v0.1")
//                    .font(.system(size: 10)) // This sets the font size to 10 points
//            }

            // Countdown Timer
            HStack {
                Image(systemName: "clock")
                Text("Next update in:")
                Text(formattedTimeRemaining)
                    .bold()
                    .monospacedDigit()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }

        .padding()
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timeRemaining = timerInterval
            }
            
            
        }
       
        //Not getting printed in the end
//        HStack {
//            Text("By: Aaryan Deshwal")
//                .font(.system(size: 10)) // This sets the font size to 10 points
//            Spacer() // This pushes the owner name to the right
//            Text("v0.1")
//                .font(.system(size: 10)) // This sets the font size to 10 points
//        }
                
     
    }
    
    
  
  
    
    private func getWeatherIcon(condition: String) -> String {
        switch condition.lowercased()  {
        case let c where c.contains("thunderstorm"): return "cloud.bolt.rain"
        case let c where c.contains("drizzle"): return "cloud.drizzle"
        case let c where c.contains("rain"): return "cloud.rain"
        case let c where c.contains("snow"): return "cloud.snow"
        case let c where c.contains("clear"): return "sun.max"
        case let c where c.contains("clouds"): return "cloud"
        case let c where c.contains("mist"), let c where c.contains("smoke"), let c where c.contains("haze"), let c where c.contains("sand"), let c where c.contains("dust"), let c where c.contains("fog"): return "cloud.fog"
        case let c where c.contains("tornado"): return "tornado"
        case let c where c.contains("squall"): return "wind"
        default: return "questionmark.circle"
        }
    }
}

struct WeatherInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
