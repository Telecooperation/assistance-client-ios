//
//  ServerConnection.swift
//  Labels
//
//  Created by Nickolas Guendling on 21/07/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

typealias Result = () throws -> AnyObject

class ServerConnection: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    enum Error: ErrorType {
        case Unauthorized
        case NoInternetConnection
        case ResponseFormatError
        case RequestError(errorCode: Int)
        case ServerError(errorCode: Int)
    }
    
    static let errorMessage: [Int: String] = [
        0: "Unspecified error",
        1: "Unauthorized",
        2: "Incorrect email/password",
        3: "An account with the provided email already exists.",
        4: "Not all parameters (email and password) were provided.",
        5: "The module id was not provided.",
        6: "The module is already activated.",
        7: "The module is not activated.",
        8: "The module does not exist.",
        9: "The user is already logged in.",
        10: "Missing parameters (general).",
        11: "Invalid parameters (general).",
        12: "Device ID not known.",
        13: "Platform is not supported."
    ]
    
    func get(url: String, token: String?, completed: (result: Result) -> Void) {
        sendRequest("GET", url: url, token: token, params: nil, completed: completed)
    }
    
    func post(url: String, token: String?, params: [String: AnyObject], completed: (result: Result) -> Void) {
        sendRequest("POST", url: url, token: token, params: params, completed: completed)
    }
    
    func put(url: String, token: String?, params: [String: AnyObject], completed: (result: Result) -> Void) {
        sendRequest("PUT", url: url, token: token, params: params, completed: completed)
    }
    
    private func sendRequest(httpMethod: String, url: String, token: String?, params: [String: AnyObject]?, completed: (result: Result) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        request.HTTPMethod = httpMethod
        
        if let params = params {
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                print(try? NSJSONSerialization.JSONObjectWithData(request.HTTPBody!, options: []))
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            } catch let error as NSError {
                print(error.localizedDescription)
                request.HTTPBody = nil
            }
        }
        
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "X-AUTH-TOKEN")
            print("token: ", token)
        }
        
        print("request:", request)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            if let data = data {
                print("response: \(response)")
                print("body: \(NSString(data: data, encoding: NSUTF8StringEncoding))")
                
                if let response = response as? NSHTTPURLResponse {
                    var errorCode = 0
                    
                    do {
                        if let dataString = NSString(data: data, encoding: NSUTF8StringEncoding) where dataString.length > 0 {
                            let dataJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? NSDictionary
                            
                            if let dataJSON = dataJSON {
                                if let code = dataJSON["code"] as? Int {
                                    errorCode = code
                                }
                                if let device_id = dataJSON["device_id"] as? Int {
                                    NSUserDefaults.standardUserDefaults().setObject(device_id, forKey: "device_id")
                                }
                            }
                        }
                    } catch {
                        completed(result: { throw Error.ResponseFormatError })
                    }
                        
                    switch response.statusCode {
                        case 200: completed(result: { return data })
                        case 400: completed(result: { throw Error.RequestError(errorCode: errorCode) })
                        case 401: completed(result: { throw Error.Unauthorized })
                        case 404: completed(result: { throw Error.ServerError(errorCode: 404) })
                        case 500: completed(result: { throw Error.ServerError(errorCode: 500) })
                        default: ()
                    }
                } else {
                    completed(result: { throw Error.NoInternetConnection })
                }
            }
        })
        
        task.resume()
    }

    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        let newRequest: NSURLRequest? = request
        completionHandler(newRequest)
    }
    
}