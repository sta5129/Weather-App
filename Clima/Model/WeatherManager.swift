//
//  WeatherManager.swift
//  Clima
//
//  Created by Samarah Anderson on 4/29/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

//translating JSON into swift

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError (error: Error)
}

//performs the networking that fetches live data from open weather map and parse the weather into a swift object
struct WeatherManager {
    
    
    //property. the part of the URL we are changing is the city input
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=95986ba1ac70c029cb764576858161c7&units=imperial"
    //delegate property
    var delegate: WeatherManagerDelegate?
    
    //fetch method takes city name and creates a url string
    func fetchWeather(cityName: String) {
        //creating url string based on the city user inputs
        let urlString = "\(weatherURL)&q=\(cityName)"
        
        //calling the performRequest method and passing in urlString
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //creating url string based on the longitude and latitiude user inputs
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    //method that makes the request for the data which is based on the urlString
    func performRequest(with urlString: String) {
        
        //1. create URL
        if let url = URL(string: urlString) {
            
            //2. create URL session
            let session = URLSession(configuration: .default)
            
            //3. give URL session a task
            //Completion handler: Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.
            //Closure
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    //passing error back to delegate
                    self.delegate?.didFailWithError(error: error!)
                    
                    //keyword return by itself means exit out of the func
                    return
                }
                
                //check what data we got back. using optional binding to unwrap the data object
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //4. start task
            task.resume()
        }
    }
    
    //decoding the data
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        //do is always executed. if try is successful code flows to the code immediately after try keyword. if try throws error code jumps to catch.
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            //passing error back to delegate
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

