//
//  WeatherResponse.swift
//  Weather
//
//  Created by Ilya Lebedev on 10/08/2019.
//  Copyright © 2019 Ilya Lebedev. All rights reserved.
//

import Foundation

struct WeatherResponse: Decodable {
    struct MainWeather: Decodable {
        let temp: Double
    }
    struct Weather: Decodable {
        let main: String
    }
    let coord: [String: Double]
    let main: MainWeather
    let weather: [Weather]
}
