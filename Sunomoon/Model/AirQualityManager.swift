//
//  WeatherManager.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/17/21.
//

import Foundation
import CoreLocation

protocol AirQualityManagerDelegate {
    func didUpdateAirQuality(airQualityManager: AirQualityManager, airQuality: AirQualityModel)
    func didAirQualityManagerFailWithError(error: Error)
}

struct AirQualityManager {
    let airQualityURL = "https://api.openweathermap.org/data/2.5/air_pollution?appid=fe0b2f2db930e017158c5225c94706ad"
    var delegate: AirQualityManagerDelegate?

    func getCurrentLocationAirQuality(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(airQualityURL)&lat=\(lat)&lon=\(lon)"
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
                    self.delegate?.didAirQualityManagerFailWithError(error: error!)
                    return
                }

                if let safeData = data {
                    let dataString = String(data: safeData, encoding: .utf8)
                    //print("dataString: \(dataString)")
                    if let airQuality = paseJason(airQualityData: safeData) {
                        self.delegate?.didUpdateAirQuality(airQualityManager: self, airQuality: airQuality)
                    }
                }
            }
            //4. start the task
            task.resume()
        }
    }

    func paseJason(airQualityData: Data) -> AirQualityModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(AirQualityData.self, from: airQualityData)
            //print("decodeData: \(decodeData)")
            // name must same as in the web
            let aqi = decodeData.list[0].main.aqi
            let pm2_5 = decodeData.list[0].components.pm2_5
            let airQuality = AirQualityModel(aqi: aqi, pm2_5: pm2_5)
            return airQuality
        }
        catch {
            delegate?.didAirQualityManagerFailWithError(error: error)
            return nil
        }
    }
}
