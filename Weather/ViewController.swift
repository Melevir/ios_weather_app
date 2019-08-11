//
//  ViewController.swift
//  Weather
//
//  Created by Ilya Lebedev on 09/08/2019.
//  Copyright © 2019 Ilya Lebedev. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet private weak var temperatureTextField: UITextField!
    @IBOutlet private weak var cityNameTextField: UITextField!
    @IBOutlet private weak var weatherIconTextField: UITextField!
    @IBOutlet private weak var scrollView: UIScrollView!

    private let cities = ["Moscow", "London", "Paris", "New York"]
    private var currentCity: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAndShowDataFor(cities.randomElement()!)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateWeatherData), for: .valueChanged)
        scrollView.refreshControl = refreshControl

        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector(("swipeAction:")))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }

    @objc private func updateWeatherData(refreshControl: UIRefreshControl) {
        fetchAndShowDataFor(currentCity!)
        refreshControl.endRefreshing()
    }

    @objc private func swipeAction(_ sender: UIGestureRecognizer) {
        fetchAndShowDataFor(cities.randomElement()!)
    }

    private func fetchAndShowDataFor(_ city: String) {
        currentCity = city
        getCurrentTemperatureCelsius(cityName: city, callback: { [weak self] in
            guard let self = self else {
                return
            }

            self.temperatureTextField.text = "\(Int($0.main.temp))°c"
            self.cityNameTextField.text = city
            self.weatherIconTextField.text = String ($0.weather.first!.main)
        })
    }

    private func getCurrentTemperatureCelsius(cityName: String, callback: @escaping (WeatherResponse) -> Void) {
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
                } catch {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Error receiving data from OWM",
                        preferredStyle: UIAlertController.Style.alert
                    )
                    alert.addAction(UIAlertAction(
                        title: "Retry",
                        style: UIAlertAction.Style.default,
                        handler: {_ in self.fetchAndShowDataFor(self.currentCity!)}
                    ))
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
}
