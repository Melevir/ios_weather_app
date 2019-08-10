//
//  ViewController.swift
//  Weather
//
//  Created by Ilya Lebedev on 09/08/2019.
//  Copyright © 2019 Ilya Lebedev. All rights reserved.
//

import UIKit
import Alamofire

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

class ViewController: UIViewController {
  @IBOutlet weak var temperatureTextField: UITextField!
  @IBOutlet weak var cityNameTextField: UITextField!
  @IBOutlet weak var weatherIconTextField: UITextField!
  @IBOutlet weak var scrollView: UIScrollView!

  let cities = ["Moscow", "London", "Paris", "New-York"]
  var currentCity: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    fetchAndShowDataFor(cities.randomElement()!)

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(updateWeatherData), for: .valueChanged)
    scrollView.refreshControl = refreshControl
  }

  @objc func updateWeatherData(refreshControl: UIRefreshControl) {
    fetchAndShowDataFor(currentCity!)
    refreshControl.endRefreshing()
  }

  @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
    fetchAndShowDataFor(cities.randomElement()!)
  }

  func fetchAndShowDataFor(_ city: String) {
    currentCity = city
    getCurrentTemperatureCelsius(cityName: city, callback: {
      self.temperatureTextField.text = "\(Int($0.main.temp))°c"
      self.cityNameTextField.text = city
      self.weatherIconTextField.text = String ($0.weather.first!.main)
    })
  }

  func getCurrentTemperatureCelsius(cityName: String, callback: @escaping (WeatherResponse) -> Void) {
    Alamofire.request(
      "https://api.openweathermap.org/data/2.5/weather",
      parameters: [
        "q": cityName,
        "appid": Bundle.main.infoDictionary?["OWM_API_KEY"] as! String,  // swiftlint:disable:this force_cast
        "units": "Metric"
      ]
    ).responseJSON { response in
      do {
      let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: response.data!)
      callback(weatherData)
      } catch let error {
        print("error: \(error)")
      }
    }
  }
}
