//
//  NetworkManager.swift
//  Avatarly
//
//  Created by Shahid Iqbal on 16/08/2023.
//

import SwiftUI

//let apiURL = "http://43.240.15.72:8605/" // hk
let apiURL = "https://avatarly.ai/api/" // us test

enum endpoint: String {
    case appUpload
    case appStatus
    case appHDStatus // check高清图的status
    case appAgain
    case appUpscale
    case appleSignIn // 苹果登录
    case updateUserCredit  // 更新登录用户的数据库存的credits
    case purchasedUserCredit // 支付成功后更新用户的credits
    case fetchUserCredit
}

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    private override init() {}
    
    func accessBaidu() {
        guard let url = URL(string: "https://www.baidu.com") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (_, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("Success! HTTP Status Code: \(httpResponse.statusCode)")
                } else {
                    print("Unexpected HTTP Status Code: \(httpResponse.statusCode)")
                }
            }
        }

        task.resume()
    }

    
//    func uploadImageFile (
//        imgFileData: Data, gender: String, completion: @escaping (Result<imgResponse, Error>) -> Void) {
//            
//            let name = "myfile"
//            let fileName = "avatar.jpg"
//            
//            
//            let uploadApiUrl: URL? = URL(string: "\(apiURL)\(endpoint.appUpload.rawValue)")
//            
//            // Generate a unique boundary string using a UUID.
//            let uniqueBoundary = UUID().uuidString
//            
//            var bodyData = Data()
//            print("before gender ====== \(gender)")
//            // Add the multipart/form-data raw http body data.
//            bodyData.append("\r\n--\(uniqueBoundary)\r\n".data(using: .utf8)!)
//            bodyData.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
//            bodyData.append("\(gender)\r\n".data(using: .utf8)!)
//            
//            bodyData.append("\r\n--\(uniqueBoundary)\r\n".data(using: .utf8)!)
//            bodyData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
//            bodyData.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
//            
//            // Add the file data to the raw http body data.
//            bodyData.append(imgFileData)
//    
//            // End the multipart/form-data raw http body data.
//            bodyData.append("\r\n--\(uniqueBoundary)--\r\n".data(using: .utf8)!)
//            
//            let urlSessionConfiguration = URLSessionConfiguration.default
//            
//            let urlSession
//                = URLSession(
//                    configuration: urlSessionConfiguration,
//                    delegate: self,
//                    delegateQueue: nil)
//            
//            var urlRequest = URLRequest(url: uploadApiUrl!)
//            
//            // Set Content-Type Header to multipart/form-data with the unique boundary.
//            urlRequest.setValue("multipart/form-data; boundary=\(uniqueBoundary)", forHTTPHeaderField: "Content-Type")
//            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
//            
//            urlRequest.httpMethod = "POST"
//            
//            let task = urlSession.uploadTask(with: urlRequest, from: bodyData) { (data, urlResponse, error) in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                
//                if let data = data {
//                    do {
//                        let res = try JSONDecoder().decode(imgResponse.self, from: data)
//                        completion(.success(res))
//                    } catch let error {
//                        completion(.failure(error))
//                    }
//                }
//            }
//            task.resume()
//    }
//    
//    func fetchAvatars (taskID: String, completion: @escaping (avatarResponse) -> Void) {
//        let url = URL(string: "\(apiURL)\(endpoint.appStatus.rawValue)/\(taskID)")!
//
//            let task = URLSession.shared.dataTask(with: url) { data, response, error in
//                guard
//                    error == nil,
//                    let data = data
//                else {
//                    print(error ?? "Unknown error")
//                    return
//                }
//                do {
//                     let res = try JSONDecoder().decode(avatarResponse.self, from: data)
//                    print("before comp1 ======")
//                    print(res)
//                     completion(res)
//                  } catch let error {
//                      print("let error1 ======")
//                     print(error)
//                  }
//            }
//            task.resume()
//    }
//    
//    func fetchHDAvatar (taskID: String, index: Int, completion: @escaping (avatarHDResponse) -> Void) {
//        let url = URL(string: "\(apiURL)\(endpoint.appHDStatus.rawValue)/\(taskID)/\(index)")!
//            
//            let task = URLSession.shared.dataTask(with: url) { data, response, error in
//                guard
//                    error == nil,
//                    let data = data
//                else {
//                    print(error ?? "Unknown error")
//                    return
//                }
//                do {
//                     let res = try JSONDecoder().decode(avatarHDResponse.self, from: data)
//                    print("before comp2 ====== \(url)")
//                    print(res)
//                     completion(res)
//                  } catch let error {
//                      print("let error2 ====== \(url)")
//                     print(error)
//                  }
//            }
//            task.resume()
//    }
//    
//    func generateAgain (
//        taskID: String, gender: String, completion: @escaping (regenResponse) -> Void) {
//            
//            let taskKey = "taskID"
//            let genderKey = "gender"
//            print(taskID)
//            print(gender)
//            
//            let uploadApiUrl: URL? = URL(string: "\(apiURL)\(endpoint.appAgain.rawValue)")
//            
//            // Generate a unique boundary string using a UUID.
//            let uniqueBoundary = UUID().uuidString
//            
//            var bodyData = Data()
//            
//            // Add the multipart/form-data raw http body data.
//            bodyData.append("\r\n--\(uniqueBoundary)\r\n".data(using: .utf8)!)
//            bodyData.append("Content-Disposition: form-data; name=\"\(taskKey)\"\r\n\r\n".data(using: .utf8)!)
//            bodyData.append("\(taskID)\r\n".data(using: .utf8)!)
//            
//            bodyData.append("\r\n--\(uniqueBoundary)\r\n".data(using: .utf8)!)
//            bodyData.append("Content-Disposition: form-data; name=\"\(genderKey)\"\r\n\r\n".data(using: .utf8)!)
//            bodyData.append("\(gender)\r\n".data(using: .utf8)!)
//            bodyData.append("\r\n--\(uniqueBoundary)--\r\n".data(using: .utf8)!)
//            
//            let urlSessionConfiguration = URLSessionConfiguration.default
//            
//            let urlSession
//                = URLSession(
//                    configuration: urlSessionConfiguration,
//                    delegate: self,
//                    delegateQueue: nil)
//            
//            var urlRequest = URLRequest(url: uploadApiUrl!)
//            
//            // Set Content-Type Header to multipart/form-data with the unique boundary.
//            urlRequest.setValue("multipart/form-data; boundary=\(uniqueBoundary)", forHTTPHeaderField: "Content-Type")
////            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
//            
//            urlRequest.httpMethod = "POST"
//            
//            let task = urlSession.uploadTask(with: urlRequest, from: bodyData) { (data, urlResponse, error) in
//                if let data = data {
//                    do {
//                         let res = try JSONDecoder().decode(regenResponse.self, from: data)
//                        print("before comp ======")
//                        print(res)
//                         completion(res)
//                      } catch let error {
//                          print("let error ======")
//                         print(error)
//                      }
//                }
//            }
//            task.resume()
//    }
//    
//    func downloadHD (
//        TaskID: String, Index: Int, completion: @escaping (hdResponse) -> Void) {
//            let uploadApiUrl: URL? = URL(string: "\(apiURL)\(endpoint.appUpscale.rawValue)")
//            
//            // Generate a unique boundary string using a UUID.
//            let uniqueBoundary = UUID().uuidString
//            
//            var bodyData = Data()
//            
//            // Add the "taskid" parameter
//            bodyData.append("\r\n--\(uniqueBoundary)\r\n".data(using: .utf8)!)
//            bodyData.append("Content-Disposition: form-data; name=\"taskid\"\r\n\r\n".data(using: .utf8)!)
//            bodyData.append("\(TaskID)\r\n".data(using: .utf8)!)
//            
//            // Add the "index" parameter
//           bodyData.append("\r\n--\(uniqueBoundary)\r\n".data(using: .utf8)!)
//           bodyData.append("Content-Disposition: form-data; name=\"index\"\r\n\r\n".data(using: .utf8)!)
//           bodyData.append("\(Index)\r\n".data(using: .utf8)!)
//            
//            // End the multipart form data
//            bodyData.append("\r\n--\(uniqueBoundary)--\r\n".data(using: .utf8)!)
//            
//            let urlSessionConfiguration = URLSessionConfiguration.default
//            
//            let urlSession
//                = URLSession(
//                    configuration: urlSessionConfiguration,
//                    delegate: self,
//                    delegateQueue: nil)
//            
//            var urlRequest = URLRequest(url: uploadApiUrl!)
//            
//            // Set Content-Type Header to multipart/form-data with the unique boundary.
//            urlRequest.setValue("multipart/form-data; boundary=\(uniqueBoundary)", forHTTPHeaderField: "Content-Type")
////            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
//            
//            urlRequest.httpMethod = "POST"
//            
//            let task = urlSession.uploadTask(with: urlRequest, from: bodyData) { (data, urlResponse, error) in
//                if let data = data {
//                    do {
//                         let res = try JSONDecoder().decode(hdResponse.self, from: data)
//                        print("before comp ======")
//                        print(res)
//                         completion(res)
//                      } catch let error {
//                          print("let error ======")
//                         print(error)
//                      }
//                }
//            }
//            task.resume()
//    }
//    
//    
//    func verifyIapCode (
//        url: URL, bodyData:Data, completion: @escaping (hdResponse) -> Void) {
//                        
//
//            let urlSessionConfiguration = URLSessionConfiguration.default
//            
//            let urlSession
//                = URLSession(
//                    configuration: urlSessionConfiguration,
//                    delegate: self,
//                    delegateQueue: nil)
//            
//            var urlRequest = URLRequest(url: url)
//            
//            // Set Content-Type Header to multipart/form-data with the unique boundary.
//            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//            
//            urlRequest.httpMethod = "POST"
//            
//            let task = urlSession.uploadTask(with: urlRequest, from: bodyData) { (data, urlResponse, error) in
//                if let data = data {
//                    do {
//                         let res = try JSONDecoder().decode(hdResponse.self, from: data)
//                        print("before comp ======")
//                        print(res)
//                         completion(res)
//                      } catch let error {
//                          print("let error ======")
//                         print(error)
//                      }
//                }
//            }
//            task.resume()
//    }
//    
//    func appleLogin(user_id: String,user_name: String, user_email: String, user_token: String, user_credits: Int, subscription_date: Int, subscription_type: String, subscription_status: String,  completion: @escaping (appleLoginResponse) -> Void) {
//        let urlString = "\(apiURL)\(endpoint.appleSignIn.rawValue)"
//        let url = URL(string: urlString)!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let parameters: [String: Any] = [
//            "user_id": user_id,
//            "user_name": user_name,
//            "user_email": user_email,
//            "user_token":user_token,
//            "user_credits":user_credits,
//            "subscription_date":subscription_date,
//            "subscription_type":subscription_type,
//            "subscription_status":subscription_status,
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        } catch let error {
//            print("JSON serialization error: \(error.localizedDescription)")
//            return
//        }
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard error == nil, let data = data else {
//                print(error?.localizedDescription ?? "Unknown error")
//                return
//            }
//            
//            do {
//                let res = try JSONDecoder().decode(appleLoginResponse.self, from: data)
//                print("Response: \(res)")
//                completion(res)
//            } catch let error {
//                print("JSON decoding error: \(error.localizedDescription)")
//                return
//            }
//        }
//        task.resume()
//    }
//    
//    func updateUserCreditsDB(user_id: String, user_credits: Int, completion: @escaping (updateCreditsResponse) -> Void) {
//        let urlString = "\(apiURL)\(endpoint.updateUserCredit.rawValue)"
//        let url = URL(string: urlString)!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let parameters: [String: Any] = [
//            "user_id": user_id,
//            "user_credits":user_credits
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        } catch let error {
//            print("JSON serialization error: \(error.localizedDescription)")
//            return
//        }
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard error == nil, let data = data else {
//                print(error?.localizedDescription ?? "Unknown error")
//                return
//            }
//            
//            do {
//                let res = try JSONDecoder().decode(updateCreditsResponse.self, from: data)
//                print("Response: \(res)")
//                completion(res)
//            } catch let error {
//                print("JSON decoding error: \(error.localizedDescription)")
//                return
//            }
//        }
//        task.resume()
//    }
//    
//    func updateUserSuccessfulPurchaseCredits(user_id:String,user_token:String, user_credits: Int,subscription_date: Int,subscription_type: String, subscription_status: String, completion: @escaping (purchasedUserCredit) -> Void) {
//        let urlString = "\(apiURL)\(endpoint.purchasedUserCredit.rawValue)"
//        let url = URL(string: urlString)!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let parameters: [String: Any] = [
//            "user_id": user_id,
//            "user_token": user_token,
//            "user_credits": user_credits,
//            "subscription_date": subscription_date,
//            "subscription_type": subscription_type,
//            "subscription_status": subscription_status
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        } catch let error {
//            print("JSON serialization error: \(error.localizedDescription)")
//            return
//        }
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard error == nil, let data = data else {
//                print(error?.localizedDescription ?? "Unknown error")
//                return
//            }
//            
//            do {
//                let res = try JSONDecoder().decode(purchasedUserCredit.self, from: data)
//                print("Response: \(res)")
//                completion(res)
//            } catch let error {
//                print("JSON decoding error: \(error.localizedDescription)")
//                return
//            }
//        }
//        task.resume()
//    }
//    
//    func fetchUserCredit(user_id:String,subscription_date: Int,subscription_type: String, subscription_status: String, completion: @escaping (fetchUserCreditResponse) -> Void) {
//        let urlString = "\(apiURL)\(endpoint.fetchUserCredit.rawValue)"
//        let url = URL(string: urlString)!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let parameters: [String: Any] = [
//            "user_id": user_id,
//            "subscription_date": subscription_date,
//            "subscription_type": subscription_type,
//            "subscription_status": subscription_status
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        } catch let error {
//            print("JSON serialization error: \(error.localizedDescription)")
//            return
//        }
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard error == nil, let data = data else {
//                print(error?.localizedDescription ?? "Unknown error")
//                return
//            }
//            
//            do {
//                let res = try JSONDecoder().decode(fetchUserCreditResponse.self, from: data)
//                print("Response: \(res)")
//                completion(res)
//            } catch let error {
//                print("JSON decoding error: \(error.localizedDescription)")
//                return
//            }
//        }
//        task.resume()
//    }
}
extension NetworkManager: URLSessionTaskDelegate {
                
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64) {
        
        print("fractionCompleted  : \(Int(Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100))")
            
    }
    
}

