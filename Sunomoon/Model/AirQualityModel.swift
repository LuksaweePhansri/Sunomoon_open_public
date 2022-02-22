//
//  AirQualityModel.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/18/21.
//

import Foundation
struct AirQualityModel {
    let aqi: Int
    let pm2_5: Double
    
    var aqiString: String {
        return String(aqi)
    }
    
    var airQualityLevel: String {
        switch aqi {
        case 0...50:
            return "Good"
        case 51...100:
            return "Moderate"
        case 101...150:
            return "Unhealthy for Sensitive Groups"
        case 151...200:
            return "Unhealthy"
        case 201...300:
            return "Very Unhealthy"
        case 301...500:
            return "Hazardous"
        default:
            return ""
        }
    }
    
    var airQualityAdvise: String {
        switch aqi {
        case 0...50:
            return "Enjoy outdoor activities"
        case 51...100:
            return "Sensitive groups should reduce outdoor exercise"
        case 101...150:
            return "Everyone should reduce outdoor exercise, and keep doors and windows closed"
        case 151...200:
            return "Avoid outdoor exercise, keep doors and windows closed, and wear a mask outdoors"
        case 201...300:
            return "Avoid outdoor exercise, keep doors and windows closed, and wear a mask outdoors"
        case 301...500:
            return "Avoid outdoor exercise, keep doors and windows closed, and wear a mask outdoors"
        default:
            return ""
        }
    }
    
}


