//
//  ContentView.swift
//  GetTheSun
//
//  Created by Aaryan Deshwalon 1/6/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var weatherService: WeatherService
    @State private var showingAbout = false

    
    var body: some View {
        NavigationView {
            Group {
                switch weatherService.locationStatus {
                case .unknown:
                    ProgressView("Checking location permissions...")
                case .noPermission:
                    LocationPermissionView(errorMessage: weatherService.errorMessage ?? "")
                case .error:
                    ErrorView(message: weatherService.errorMessage ?? "Something went wrong. Please try again.")
                case .permissionGranted:
                    if let weather = weatherService.currentWeather {
                        WeatherDisplay(weather: weather, isTestMode: false) // Set to true for testing
                    } else {
                        ProgressView("Fetching weather data...")
                    }
                  
                }
            }
            .padding()
            .navigationTitle("Get the Sun ☀️")
            
            
                
                
            
        }
        HStack {
         
            Text(" By: Aaryan Deshwal (v0.1)")
                    .font(.system(size: 10)) // This sets the font size to 10 points
            
            Spacer() // This pushes the owner name to the right
            
            Button("About App ") {
                showingAbout = true
            }
            .foregroundColor(.blue) // Set the color to blue
            .underline() // Add an underline to make it look like a hyperlink
           
           

        }
        .alert("About App", isPresented: $showingAbout) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\"Get the Sun\" was created to help you prioritize your health and well-being by making it easier to get the vitamin D you need from the sun.\nWe believe that spending time in nature is essential for both physical and mental health. That's why we created this app to help you find the perfect times to get some sun exposure based on the weather in your location regularly and sends notifications to your phone and smartwatch, highlighting ideal times throughout the day to step outside.\nWe hope that \"Get the Sun\" will have a positive impact on your health and wellness.\nPlease note: This app is intended for informational purposes only. Please use your judgment, health, environmental, and other factors when making decisions about following app's suggestion. The app and its creator/publisher are not responsible for any loss or damages.")
            
        }
    
        
        
        
    }
}

struct LocationPermissionView: View {
    let errorMessage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(errorMessage)
                .multilineTextAlignment(.center)
            
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
