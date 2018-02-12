//
//  CityWeather.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import Foundation

struct CityWeather: Decodable {
    let cnt: Int
    let list: [WeatherInfo]
    struct WeatherInfo: Decodable {
        let name: String
        let id: Int
        let weather: [Weather]
        let main: MainWeatherInfo
        struct Weather: Decodable {
            let description: String
            let icon: String
        }
        struct MainWeatherInfo: Decodable {
            let temp: Double
        }
    }
}
