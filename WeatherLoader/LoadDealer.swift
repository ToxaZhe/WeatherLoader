//
//  LoadDealer.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import Foundation
enum Result<T> {
    case data(Data)
    case statusCode(Int)
}

class LoadDealer {
    static let sharedInstance = LoadDealer()
    func loadData(fromUrl url: URL, completion: @escaping(Result<Any>) -> Void)  {
        var request = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
        let headers = [
            "cache-control": "no-cache",
            ]
        // We can use POST and send request params in requestBody
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(Result.statusCode((error! as NSError).code))
                return
            }
            let httpResponse = response as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 || httpResponse?.statusCode == nil else {
                completion(Result.statusCode(httpResponse!.statusCode))
                return
            }
            guard let data = data else {
                return
            }
            completion(Result.data(data))
        }
        task.resume()
    }
    func handleRequestedResult(result: Result<Any>) -> Any {
        switch result {
        case .statusCode(let statusCode):
            return statusCode
        case .data(let data):
            return data
        }
    }
}
