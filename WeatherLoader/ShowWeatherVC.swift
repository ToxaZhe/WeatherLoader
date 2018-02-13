//
//  ViewController.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit
protocol NoConnectionVCDelegate: class {
    func isConnectedToNetwork()
}
protocol ShowWeatherVCDelegate {
    func fillWeatherModels()
}

class ShowWeatherVC: UIViewController {
    @IBOutlet weak var citiesWeatherCollectionView: UICollectionView!
    let weatherApi = WeatherApi(downloader: LoadDealer.sharedInstance)
    let weatherCellIdentifier = "WeatherCell"
    let imageNotAviable = UIImage.init(named: "noImageAviable")
    let idParametrName = "&id="
    var fillingCities = true
    var indexPath = IndexPath.init(row: 0, section: 1)
    var weatherModels = [WeatherModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkNetworkandBeginDownload()
    }
  
    func checkNetworkandBeginDownload() {
        guard Connectivity.isConnectedToNetwork() == false else {
            fillWeatherModels()
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVCIdentifier") as? NoConnectionVC
        {
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
        
        
    }
    
}
extension ShowWeatherVC: ShowWeatherVCDelegate {
    func prepareCityIds() -> String {
        let coma = ","
        var citiesIdsStringParam = idParametrName
        for cityId in WeatherApi.citiesDict {
            citiesIdsStringParam = citiesIdsStringParam + cityId.value + coma
        }
        citiesIdsStringParam.removeLast()
        return citiesIdsStringParam
    }
    func fillWeatherModels() {
        fillingCities = true
        weatherApi.getCities(fromIds: prepareCityIds(), onSuccess: { (data) in
            self.fillModels(fromData: data)
        }) { (errorCode) in
            print(errorCode)
        }
    }
    func fillModels(fromData data: Data) {
        do {
            let decoder = JSONDecoder()
            let weather = try decoder.decode(CityWeather.self, from: data)
            for cityWeather in weather.list {
                let temp = Int.init(cityWeather.main.temp)
                let cityName = cityWeather.name
                let cityId = cityWeather.id
                guard let weatherData = cityWeather.weather.first else {return}
                let weatherDescription = weatherData.description
                let iconName = weatherData.icon
                getWeatherIcon(byName: iconName, andFillModelWith: cityName, cityId: cityId, temp: temp, description: weatherDescription)
            }
        } catch let jsonErr {
            print(jsonErr.localizedDescription)
        }
    }
    func getWeatherIcon(byName name: String, andFillModelWith cityName: String, cityId: Int, temp: Int, description: String) {
        weatherApi.getWeatherIcon(by: name, onSuccess: { (data) in
            guard let image = UIImage.init(data: data) else {
                return
            }
            let weatherModel = WeatherModel(temp: temp, description: description , image: image, cityName: cityName, cityId: cityId)
                self.handleImageDownloading(image: image, toWeatherModel: weatherModel)
        }, onError: { (errCode) in
            let weatherModel = WeatherModel(temp: temp, description: description, image: #imageLiteral(resourceName: "noImageAvailable") , cityName: cityName, cityId: cityId)
                self.handleImageDownloading(image: nil, toWeatherModel: weatherModel)
        })
    }
    func handleImageDownloading (image: UIImage?, toWeatherModel model:WeatherModel){
        var weatherModel = model
        if let image = image {
            weatherModel.image = image
        }
        if fillingCities {
            self.weatherModels.append(weatherModel)
            DispatchQueue.main.async {
                self.citiesWeatherCollectionView.reloadData()
            }
        } else {
            self.weatherModels.remove(at: indexPath.row)
            self.weatherModels.insert(weatherModel, at: indexPath.row)
            DispatchQueue.main.async {
                self.citiesWeatherCollectionView.reloadItems(at: [self.indexPath])
            }
        }
    }
    func reloadCell(atIndexPath indexPath: IndexPath) {
        fillingCities = false
        self.indexPath = indexPath
        let cityIdParam = idParametrName + String(weatherModels[indexPath.row].cityId)
        weatherApi.getCities(fromIds: cityIdParam, onSuccess: { (data) in
            self.fillModels(fromData: data)
        }) { (errorCode) in
            print(errorCode)
        }
    }
}
extension ShowWeatherVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weatherCellIdentifier, for: indexPath) as! WeatherCell
        let temp = weatherModels[indexPath.row].temp
        cell.weatherTempLabel.text = String(temp)
        if temp > 0 {
            cell.weatherTempLabel.textColor = UIColor.red
        } else {
            cell.weatherTempLabel.textColor = UIColor.blue
        }
        cell.weatherIconImageView.image = weatherModels[indexPath.row].image
        cell.weatherDescriptionLabel.text = weatherModels[indexPath.row].description
        cell.cityName.text = weatherModels[indexPath.row].cityName
        cell.refreshAction = {[weak self] in
            self?.reloadCell(atIndexPath: indexPath)
        }
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        reloadCell(atIndexPath: indexPath)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = citiesWeatherCollectionView.frame.size.width
        let height = citiesWeatherCollectionView.frame.size.height*0.99
        return CGSize.init(width: width, height: height)
    }
}

extension ShowWeatherVC: NoConnectionVCDelegate {
    func isConnectedToNetwork() {
        fillWeatherModels()
    }
    
    
}


