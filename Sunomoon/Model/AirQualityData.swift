struct AirQualityData: Codable {
    let list: [List]
}

struct List: Codable {
    let main: MainAirQuality
    let components: ComponentAirQuality
}

struct MainAirQuality: Codable {
    let aqi: Int
}

struct ComponentAirQuality: Codable {
    let pm2_5: Double
}
