//
//  Client.swift
//  Nasa App
//
//  Created by Lucas Daniel on 17/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation

class Client : NSObject {
    
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    func getData(sonda: String, date: Date, result: @escaping (_ result: PhotosParser?, _ error: NSError?) -> Void) -> URLSessionDataTask {
               
        let parameters: [String: String] = [
            "earth_date": getYesterdayDateString(starterDate: date),
            "api_key": Constants.apiKey
        ]
        let request = NSMutableURLRequest(url: buildURLFromParameters(sonda: sonda, parameters, withPathExtension: "\(sonda)/photos"))
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                result(nil, NSError(domain: "getData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            if let code = response as? HTTPURLResponse {
                if code.statusCode == 429 {
                    sendError("limit")
                    return
                }
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Erro ao realizar a requisição. Tente mais tarde novamente!")
                return
            }
            
            guard let data = data else {
                sendError("Nenhum dado foi retornado!")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let photosParsed = try decoder.decode(PhotosParser.self, from: data)
                result(photosParsed, nil)
            } catch {
                sendError("Ocorreu um erro. Tente mais tarde novamente!")
            }
            
        }
        
        task.resume()
        return task
    }
        
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
    
    func getYesterdayDateString(starterDate: Date) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"        
        if let date = dateFormatter.date(from: dateFormatter.string(from: starterDate)) {
            return(dateFormatter.string(from: date))
        }
        return ""
    }
    
    private func buildURLFromParameters(sonda: String, _ parameters: [String: String], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}
