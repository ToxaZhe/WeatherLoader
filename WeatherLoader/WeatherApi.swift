//
//  WeatherApi.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import Foundation


class WeatherApi {
    let downloader: LoadDealer
    init(downloader: LoadDealer) {
        self.downloader = downloader
    }
    static let citiesDict: [String : String] = {
        let cities = [katmandu : "1271881", delphi : "1273294", muenchen : "2867714", vienna : "2761369", loffenau : "2876462", koge : "2618415", spezzano : "2523023", requena : "2511930", savoy : "4910663", kars : "743952"]
        return cities
    }()
    private let baseUrlString = "http://api.openweathermap.org/data/2.5/"
    private let groupEndPoint = "group?"
    private let weatherEndPoint = "weather?"
    private let appId = "appId=d2bd923726d8850b7677856f80cb52cd"
    private let weatherUnit = "&units=metric"
    private let baseImageUrlString = "http://openweathermap.org/img/w/"
    private let imageExtension = ".png"
    func getCities(fromIds ids: String, onSuccess: @escaping(Data) -> Void, onError: @escaping(Int) -> Void) {
        let completeUrlString = baseUrlString + groupEndPoint + appId + ids + weatherUnit
        guard let url = URL.init(string: completeUrlString) else {
            return
        }
        downloader.loadData(fromUrl: url) { (result) in
            let resultData = self.downloader.handleRequestedResult(result: result)
            switch resultData {
            case let errorCode as Int:
                onError(errorCode)
            case let data as Data:
                onSuccess(data)
            default:
                break
            }
        }
    }
    func getWeatherIcon(by name: String, onSuccess: @escaping(Data) -> Void, onError: @escaping(Int) -> Void) {
        let fullImageUrlString = baseImageUrlString + name + imageExtension
        guard let url = URL.init(string: fullImageUrlString) else {
            return
        }
        downloader.loadImage(fromUrl: url) { (result) in
            let resultData = self.downloader.handleRequestedResult(result: result)
            switch resultData {
            case let errorCode as Int:
                onError(errorCode)
            case let data as Data:
                onSuccess(data)
            default:
                break
            }
        }
    }
}
