//
//  DataModel.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/2/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import Foundation
import MapKit
import WebKit

class Result {
    
    var title: String
    var summary: String
    var feature: String
    var url: String
    var thumbnail: UIImage
    var longitude: Double
    var latitude: Double
    var saved = false
    
    init() {
        title = ""
        summary = ""
        feature = ""
        url = ""
        longitude = 0
        latitude = 0
        thumbnail = UIImage()
    }
    
    init(t: String, s: String?, f: String?, u: String, th: String?, lon: Double, lat: Double) {
        title = t
        if let sum = s {
            summary = sum
        } else {
            summary = ""
        }
        if let feat = f {
            feature = feat
        } else {
            feature = ""
        }
        url = u
        longitude = lon
        latitude = lat
        thumbnail = UIImage(named: "defaultlocation.jpg")!
        if let thumb = th {
            thumbnail = downloadImage(url: thumb)
        }
    }
    
    private func downloadImage(url: String) -> UIImage {
        var ret: UIImage = UIImage(named: "defaultlocation.jpg")!
        let semaphore = DispatchSemaphore(value: 0);
        let catPictureURL = URL(string: url)!
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        ret = UIImage(data: imageData)!
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
            semaphore.signal();
        }
        downloadPicTask.resume()
        semaphore.wait(timeout: .distantFuture)
        return ret
    }
}

class DataModel {
    
    var results = [Result]()
    
    func fetchJSON(term: String, username: String) -> (success: Bool, results: String) {
        var res = false
        var JSONdata = ""
        let semaphore = DispatchSemaphore(value: 0);
        let urlString = "http://api.geonames.org/wikipediaSearchJSON?formatted=true&q="+term.removingWhitespaces()+"&maxRows=20&username="+username+"&style=full"
        let url = URL(string: urlString)!
        let urlSession = URLSession.shared
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            let jsonResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            if let dat = jsonResult["geonames"] as? NSArray {
                res = true
                JSONdata = jsonResult.description
                self.results = []
                self.parseResults(data: dat)
            }
            semaphore.signal();
        })
        jsonQuery.resume()
        semaphore.wait(timeout: .distantFuture)
        return (res, JSONdata)
    }
    
    func parseResults(data: NSArray) {
        let queue = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 0)
        for i in 0..<data.count {
            let inc = data[i] as? [String: AnyObject]
            let summary = inc!["summary"] as! String?
            let title = inc!["title"] as! String
            let feature = inc!["feature"] as! String?
            let longitude = inc!["lng"] as! NSNumber
            let latitude = inc!["lat"] as! NSNumber
            let url = inc!["wikipediaUrl"] as! String
            let thumbnailURL = inc!["thumbnailImg"] as! String?
            queue.enter()
            self.results.append(Result(t: title, s: summary, f: feature, u: url, th: thumbnailURL, lon: longitude.doubleValue, lat: latitude.doubleValue))
            queue.leave()
        }
        queue.notify(queue: .main) {
            semaphore.signal()
        }
        semaphore.wait(timeout: .distantFuture)
    }
}

extension String {
    func removingWhitespaces() -> String {
        return trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).joined(separator: "%20")
    }
}
