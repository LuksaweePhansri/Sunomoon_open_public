//
//  WeatherManager.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/17/21.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel)
    func didWeatherManagerFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?APPID=fe0b2f2db930e017158c5225c94706ad&units=imperial"
    var delegate: WeatherManagerDelegate?
    
    func getCurrentLocationWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        //print("urlString: \(urlString)")
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        //print("urlString: \(urlString)")
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        // 1. create URL
        if let url = URL(string: urlString) {
            // 2. create URL session
            let session = URLSession(configuration: .default)
            
            // 3. give session task
            let task = session.dataTask(with: url) { (data, response, error) in
                if(error != nil) {
                    self.delegate?.didWeatherManagerFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let dataString = String(data: safeData, encoding: .utf8)
                    //print("dataString: \(dataString)")
                    if let weather = paseJason(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(weatherManager: self, weather: weather)
                    }
                }
            }
            //4. start the task
            task.resume()
        }
    }
    
    func paseJason(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            //print("decodeData: \(decodeData)")
            // name must same as in the web
            let name = decodeData.name
            let temp = decodeData.main.temp
            let id = decodeData.weather[0].id
            let description = decodeData.weather[0].description
            let weather = WeatherModel(cityName: name, temperature: temp, conditionId: id, description: description)
            return weather
        }
        catch {
            delegate?.didWeatherManagerFailWithError(error: error)
            return nil
        }
    }
}
