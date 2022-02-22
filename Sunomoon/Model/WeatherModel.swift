//
//  WeatherModel.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/17/21.
//

import Foundation

struct WeatherModel {
    let cityName: String
    let temperature: Double
    let conditionId: Int
    let description: String
    
    var tempertureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloudBolt"
        case 300...321:
            return "drizzle"
        case 500...531:
            return "rain"
        case 600...622:
            return "snow"
        case 701...781:
            return "fog"
        case 800:
            return "sunSmile"
        case 801:
            return "sunCloudy"
        case 802...804:
            return "cloudy"
        default:
            return "cloudy"
        }
    }
}
