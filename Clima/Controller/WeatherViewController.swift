//
//  ViewController.swift
//  Clima
//
//  Created by Samarah Anderson on 4/29/23.
//  Copyright © 2019 App Brewery. All rights reserved.
//

//CoreLocation getting the location data
import UIKit
import CoreLocation

//adopting superclasses and delegates
class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager() //responsible for getting current gps location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //triggering a permisson request - shows user a pop up asking permission to use location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //setting the class as the delegate
        locationManager.delegate = self
        weatherManager.delegate = self
        searchTextField.delegate = self
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        //triggering a reupdate of users current location
        locationManager.requestLocation()
    }
}
    
    //MARK: - UITextFieldDelegate;
    extension WeatherViewController: UITextFieldDelegate {
        
        @IBAction func searchButton(_ sender: UIButton) {
            //dismisses keyboard when search is pressed
            searchTextField.endEditing(true)
            
        }
        
        //making the return key on the keyboard functional. in order for the return button to work we have to add UITextField delegate and call it in the viewDidLoad func
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            searchTextField.endEditing(true)
            return true
        }
        
        //pressing search won't work until user has typed something. If nothing is in the text field and search is pressed the placeholder text changes to let the user know they have to put something in the textField
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            if textField.text != "" {
                return true
            } else {
                textField.placeholder = "Type something"
                return false
            }
            
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            
            if let city = searchTextField.text {
                weatherManager.fetchWeather(cityName: city)
            }
            
            //resetting the text field
            searchTextField.text = ""
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    extension WeatherViewController: WeatherManagerDelegate {
        
        func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
            
            //object that manages the execution of tasks serially or concurrently on your app's main thread or on a background thread
            DispatchQueue.main.sync{
                self.temperatureLabel.text = weather.temperatureString
                self.conditionImageView.image = UIImage(systemName: weather.conditionName)
                self.cityLabel.text = weather.cityName
            }
        }
        //implementing method
        func didFailWithError(error: Error) {
            print(error)
        }
    }
//using current location to get current weather
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //stopping location manager when user presses button or app loads
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon) //method
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
