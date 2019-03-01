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
        
        let request = NSMutableURLRequest(url: URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/" + sonda + "/photos?earth_date=" + getYesterdayDateString(starterDate: date) + "&api_key=U7YRh9sYiU7BH9xyg06bcZEYxeIJCNuIUrIMbYV5")!)
        
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
                print(code.statusCode)
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
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        print(parsedResult!)
        
        completionHandlerForConvertData(parsedResult!, nil)
        
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
            print(dateFormatter.string(from: date))
            return(dateFormatter.string(from: date))
        }
        return ""
    }    
}
