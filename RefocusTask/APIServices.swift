//
//  APIServices.swift
//  MobileMeeSeva
//
//  Created by Achyut Kumar Maddela on 21/03/16.
//  Copyright © 2016 RAMINFO. All rights reserved.
//

import UIKit

class APIServices: NSObject {

    //GET
   class func getUrlSession(_ url: String,completion completionHandler: @escaping (_ response: AnyObject) -> ()) {

    var tempJson: AnyObject?
    let session = URLSession.shared

    let task = session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in

        guard let responseData = data else {
            let errorDes = error?.localizedDescription
            completionHandler(errorDes! as AnyObject)
            return
        }

        guard error == nil else {return}
        do {

            if let json = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                tempJson = json
                completionHandler(tempJson as! NSDictionary)
            
            } else if let json = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
            tempJson = json
            completionHandler(tempJson as! NSArray)
            }
        }
        catch  {
            let string = "Server is under maintenance. Please try again after sometime."
            completionHandler(string as AnyObject)
        }
    }) 
    task.resume()
    }

    //POPULATE SURVEY NUMBERS
    class func postUrlSessionString(_ urlString: String, params: NSDictionary, completion completionHandler:@escaping (_ response: AnyObject) -> ()) {

        var tempJson: AnyObject?
        let session = URLSession.shared

        let urlStr = URL(string:urlString)
        var request = URLRequest(url: urlStr!)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "accept")

        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in

            guard let responseData = data else {return}

            guard error == nil else {return}

            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSArray {
                    tempJson = json

                    completionHandler((tempJson!) as! [NSString] as AnyObject)
                } else {
                    print("Error message dictionary it is")
                }
            } catch {
                let string = "Server is under maintenance. Please try again after sometime."
                completionHandler(string as AnyObject)
            }
            
        }) 
        task.resume()
    }
   // func asynchronousWork(completion: (inner: () throws -> NSDictionary) -> Void) -> Void {

    class func postUrlSession(_ urlString: String, params: NSDictionary, completion completionHandler:@escaping (_ response: AnyObject) -> ()) {

        var tempJson: AnyObject?
        let session = URLSession.shared

        let url = URL(string:urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "accept")

        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in

            guard let responseData = data else {
                let errorDes = error?.localizedDescription
                completionHandler(errorDes! as AnyObject)
                return
            }

            guard error == nil else {
                print(error!)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSArray {
                    tempJson = json
                    completionHandler((tempJson!))
                }
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSDictionary {
                    tempJson = json
                    completionHandler((tempJson!))
                }
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String] {
                    tempJson = json as AnyObject?
                    completionHandler((tempJson!))
                }
            } catch {
                print(response!)
                let string = "Server is under maintenance. Please try again after sometime."
                completionHandler(string as AnyObject)
            }
        }) 
        task.resume()
    }

//    class func downloadDataFromURL(url: NSURL, completion: (responseData: NSData?) -> Void) {
//
//        // Instantiate a session configuration object.
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//
//        // Instantiate a session object.
//        let session = NSURLSession(configuration: configuration)
//
//        // Create a data task object to perform the data downloading.
//        let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
//
//            if error != nil {
//                // If any error occurs then just display its description on the console.
//                print("\(error!.localizedDescription)")
//            } else {
//                if let HTTPResponse = response as? NSHTTPURLResponse {
//                    // If no error occurs, check the HTTP status code.
//                    let HTTPStatusCode = HTTPResponse.statusCode
//
//                    // If it's other than 200, then show it on the console.
//                    if HTTPStatusCode != 200 {
//                        print("HTTP status code = \(HTTPStatusCode)")
//                    }
//
//                    // Call the completion handler with the returned data on the main thread.
//                    NSOperationQueue.mainQueue().addOperationWithBlock({ completion(responseData: data)})
//                }
//            }
//        })
//
//        // Resume the task.
//        task.resume()
//    }

    
}
