//
//  UserStore.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 07/12/2023.
//

import Foundation

enum UserStoreError: Error {
    case failedDecode
    case failedToLogin
    case failedToRegister
    case failedToRecieveServerResponse
    case failedToRecievedExpectedResponse
    var localizedDescription: String {
        switch self {
        case .failedDecode: return "Failed to decode response."
        default: return "What Sticks main server is not responding."
        }
    }
}

class UserStore {
    
    let fileManager:FileManager
    let documentsURL:URL
    var user = User(){
        didSet{
            if rememberMe {
                writeUserJson()
            }
        }
    }
    var arryDashHealthDataObj:[DashboardHealthDataObject]?
    var existing_emails = [String]()
    var urlStore:URLStore!
    var requestStore:RequestStore!
    var rememberMe = false
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    init() {
        self.user = User()
        self.fileManager = FileManager.default
        self.documentsURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func callRegisterNewUser(email: String, password: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        print("- registerNewUser accessed")
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .register, body: ["new_email":email, "new_password":password])
        let task = session.dataTask(with: request) { data, response, error in
            guard let unwrappedData = data else {
                print("no data response")
                completion(.failure(UserStoreError.failedToRecieveServerResponse))
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] {
                    if let id = jsonResult["id"] as? String {
                        OperationQueue.main.addOperation {
                            completion(.success(["id": id]))
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            completion(.failure(UserStoreError.failedToRegister))
                        }
                    }
                } else {
                    throw UserStoreError.failedDecode
                }
            } catch {
                print("---- UserStore.registerNewUser: Failed to read response")
                completion(.failure(UserStoreError.failedDecode))
            }
        }
        task.resume()
    }

    func callLoginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let result = requestStore.createRequestLogin(email: email, password: password)

        switch result {
        case .success(let request):
            let task = session.dataTask(with: request) { (data, response, error) in
                // Handle the task's completion here as before
                guard let unwrapped_data = data else {
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.failedToRecieveServerResponse))
                    }
                    return
                }

                do {
                    let jsonDecoder = JSONDecoder()
                    let jsonUser = try jsonDecoder.decode(User.self, from: unwrapped_data)
                    OperationQueue.main.addOperation {
                        completion(.success(jsonUser))
                    }
                } catch {
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.failedToLogin))
                    }
                }
            }
            task.resume()

        case .failure(let error):
            // Handle the error here
            print("* error encodeing from reqeustStore.createRequestLogin")
            OperationQueue.main.addOperation {
                completion(.failure(error))
            }
        }
    }
    
    func callSendHealthDataObjects(login:Bool, completion:@escaping (Result<[DashboardHealthDataObject],Error>) -> Void){
        let request: URLRequest
        if login{
            request = requestStore.createRequestWithToken(endpoint: .send_login_health_data_objects)
        }
        else{
            request = requestStore.createRequestWithToken(endpoint: .send_dashboard_health_data_objects)
        }
        let task = requestStore.session.dataTask(with: request) { data, urlResponse, error in
            guard let unwrapped_data = data else {
                OperationQueue.main.addOperation {
                    
                    completion(.failure(UserStoreError.failedToRecieveServerResponse))
                }
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                let jsonDashHealthDataObj = try jsonDecoder.decode([DashboardHealthDataObject].self, from: unwrapped_data)
                OperationQueue.main.addOperation {
                    completion(.success(jsonDashHealthDataObj))
                }
            } catch {
                print("did not get expected response from WSAPI - probably no file for user")
                OperationQueue.main.addOperation {
                    completion(.failure(UserStoreError.failedToRecievedExpectedResponse))
                }
            }
        }
        task.resume()
    }

    
    
    func writeUserJson(){
        var jsonData:Data!

        do {
            let jsonEncoder = JSONEncoder()
            jsonData = try jsonEncoder.encode(user)
        } catch {print("failed to encode json")}
        
        let jsonFileURL = self.documentsURL.appendingPathComponent("user.json")
        do {
            try jsonData.write(to:jsonFileURL)
        } catch {
            print("Error: \(error)")
        }
    }

    func checkUserJson(completion: (Result<User,Error>) -> Void){
//        print("- checking for user.json")
        
        let userJsonFile = documentsURL.appendingPathComponent("user.json")
        
        guard fileManager.fileExists(atPath: userJsonFile.path) else {
            completion(.failure(UserStoreError.failedDecode))
            return
        }
        var user:User?
        do{
            let jsonData = try Data(contentsOf: userJsonFile)
            let decoder = JSONDecoder()
            user = try decoder.decode(User.self, from:jsonData)
        } catch {
            print("- failed to make userDict");
            completion(.failure(UserStoreError.failedDecode))
        }
        guard let unwrapped_user = user else {
            print("unwrapped_userDict failed")
            completion(.failure(UserStoreError.failedDecode))
            return
        }
        completion(.success(unwrapped_user))

    }
    
    func deleteUserJsonFile(){
        let jsonFileURL = self.documentsURL.appendingPathComponent("user.json")
        do {
            try fileManager.removeItem(at: jsonFileURL)
        } catch {
            print("No no user file")
        }
    }
    
}
