//
//  ServerConnection.swift
//  Labels
//
//  Created by Nicko on 21/07/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class ServerConnection: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    let errorMessage: [Int: String] = [
        2: "Incorrect email/password",
        3: "An account with the provided email already exists.",
        9: "The user is already logged in."
    ]
    
    func get(url: String, token: String?, completed: (succeeded: Bool, message: String) -> ()) {
        sendRequest("GET", url: url, token: token, params: nil, completed: completed)
    }
    
    func post(url: String, token: String?, params: [String: AnyObject], completed: (succeeded: Bool, message: String) -> ()) {
        sendRequest("POST", url: url, token: token, params: params, completed: completed)
    }
    
    func put(url: String, token: String?, params: [String: AnyObject], completed: (succeeded: Bool, message: String) -> ()) {
        sendRequest("PUT", url: url, token: token, params: params, completed: completed)
    }
    
    private func sendRequest(httpMethod: String, url: String, token: String?, params: [String: AnyObject]?, completed: (succeeded: Bool, message: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
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
                let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                print("body: \(dataString)")
                
                if let response = response as? NSHTTPURLResponse {
                    
                    var errorCode = 0
                    var message = ""
                    
                    do {
                        if let dataString = dataString where dataString.length > 0 {
                            let dataJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? NSDictionary
                            
                            if let dataJSON = dataJSON {
                                if let code = dataJSON["code"] as? Int {
                                    errorCode = code
                                }
                                if let token = dataJSON["token"] as? String {
                                    message = token
                                }
                                if let device_id = dataJSON["device_id"] as? Int {
                                    NSUserDefaults.standardUserDefaults().setObject(device_id, forKey: "device_id")
                                }
                            }
                        }
                    } catch {
                        completed(succeeded: false, message: "Internal format error.")
                    }
                        
                    switch response.statusCode {
                        case 200: completed(succeeded: true, message: message)
                        case 400:
                            if let errorCodeMessage = self.errorMessage[errorCode] {
                                completed(succeeded: false, message: errorCodeMessage)
                            } else {
                                completed(succeeded: false, message: "Internal Error. (\(errorCode))")
                            }
                        case 401: completed(succeeded: false, message: "Unauthorized (401)")
                        case 404: completed(succeeded: false, message: "Internal server error (404)")
                        case 500: completed(succeeded: false, message: "Internal server error (500)")
                        default: ()
                    }
                } else {
                    completed(succeeded: false, message: "Please check your internet connection!")
                }
            }
        })
        
        task.resume()
    }

    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        
        let newRequest: NSURLRequest? = request
        completionHandler(newRequest)
    }
}