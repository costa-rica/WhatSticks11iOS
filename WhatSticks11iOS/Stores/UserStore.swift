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
    case fileNotFound
    case serverError(statusCode: Int)
    var localizedDescription: String {
        switch self {
        case .failedDecode: return "Failed to decode response."
        case .fileNotFound: return "What Sticks API could not find the dashboard data on the server."
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
    var arryDataSourceObjects:[DataSourceObject]?
    var arryDashboardTableObjects:[DashboardTableObject]?
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
    
    // used in Login
    func callSendDataSourceObjects(completion:@escaping (Result<[DataSourceObject],Error>) -> Void){
//        let request: URLRequest
//        if login{
//            request = requestStore.createRequestWithToken(endpoint: .send_login_health_data_objects)
//        }
//        else{
//            request = requestStore.createRequestWithToken(endpoint: .send_dashboard_health_data_objects)
//        }
        let request = requestStore.createRequestWithToken(endpoint: .send_data_source_objects)
        let task = requestStore.session.dataTask(with: request) { data, urlResponse, error in
            guard let unwrapped_data = data else {
                OperationQueue.main.addOperation {
                    
                    completion(.failure(UserStoreError.failedToRecieveServerResponse))
                }
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                let jsonDataSourceObj = try jsonDecoder.decode([DataSourceObject].self, from: unwrapped_data)
                OperationQueue.main.addOperation {
                    completion(.success(jsonDataSourceObj))
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

    
    func callSendDashboardTableObjects(completion: @escaping (Result<[DashboardTableObject], Error>) -> Void) {
        let request = requestStore.createRequestWithToken(endpoint: .send_dashboard_table_objects)
        let task = requestStore.session.dataTask(with: request) { data, urlResponse, error in
            // Check for network errors
            if let error = error {
                OperationQueue.main.addOperation {
                    completion(.failure(error))
                }
                return
            }

            // Check for HTTP status code
            if let httpResponse = urlResponse as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    // Handle success case
                    guard let unwrappedData = data else {
                        OperationQueue.main.addOperation {
                            completion(.failure(UserStoreError.failedToRecieveServerResponse))
                        }
                        return
                    }
                    do {
                        let jsonDecoder = JSONDecoder()
                        let jsonDashboardTableObj = try jsonDecoder.decode([DashboardTableObject].self, from: unwrappedData)
                        OperationQueue.main.addOperation {
                            completion(.success(jsonDashboardTableObj))
                        }
                    } catch {
                        OperationQueue.main.addOperation {
                            completion(.failure(UserStoreError.failedToRecievedExpectedResponse))
                        }
                    }
                case 404:
                    // Handle file not found case
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.fileNotFound))
                    }
                default:
                    // Handle other HTTP errors
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.serverError(statusCode: httpResponse.statusCode)))
                    }
                }
            }
        }
        task.resume()
    }
    func writeDataSourceJson(){
        var jsonData:Data!
        do {
            let jsonEncoder = JSONEncoder()
            jsonData = try jsonEncoder.encode(arryDataSourceObjects)
        } catch {print("failed to encode json")}
        
        let jsonFileURL = self.documentsURL.appendingPathComponent("arryDataSourceObjects.json")
        do {
            try jsonData.write(to:jsonFileURL)
            print("successfully wrote arryDataSourceObjects.json")
        } catch {
            print("Error: \(error)")
        }
    }
    func checkDataSourceJson(completion: (Result<[DataSourceObject],Error>) -> Void){
        
        let userJsonFile = documentsURL.appendingPathComponent("arryDataSourceObjects.json")
        
        guard fileManager.fileExists(atPath: userJsonFile.path) else {
            completion(.failure(UserStoreError.failedDecode))
            return
        }
//        var user:User?
        do{
            let jsonData = try Data(contentsOf: userJsonFile)
            let decoder = JSONDecoder()
            self.arryDataSourceObjects = try decoder.decode([DataSourceObject].self, from:jsonData)
        } catch {
            print("- failed to make userDict");
            completion(.failure(UserStoreError.failedDecode))
        }
//        guard let unwrapped_user = user else {
//            print("unwrapped_userDict failed")
//            completion(.failure(UserStoreError.failedDecode))
//            return
//        }
        completion(.success(self.arryDataSourceObjects ?? [DataSourceObject]()))

    }
    func writeDashboardJson(){
        var jsonData:Data!
        do {
            let jsonEncoder = JSONEncoder()
            jsonData = try jsonEncoder.encode(arryDashboardTableObjects)
        } catch {print("failed to encode json")}
        
        let jsonFileURL = self.documentsURL.appendingPathComponent("arryDashboardTableObjects.json")
        do {
            try jsonData.write(to:jsonFileURL)
            print("successfully wrote arryDashboardTableObjects.json")
        } catch {
            print("Error: \(error)")
        }
    }
    func checkDashboardJson(completion: (Result<[DashboardTableObject],Error>) -> Void){
        
        let userJsonFile = documentsURL.appendingPathComponent("arryDashboardTableObjects.json")
        
        guard fileManager.fileExists(atPath: userJsonFile.path) else {
            completion(.failure(UserStoreError.failedDecode))
            return
        }
//        var user:User?
        do{
            let jsonData = try Data(contentsOf: userJsonFile)
            let decoder = JSONDecoder()
            self.arryDashboardTableObjects = try decoder.decode([DashboardTableObject].self, from:jsonData)
        } catch {
            print("- failed to make userDict");
            completion(.failure(UserStoreError.failedDecode))
        }
//        guard let unwrapped_user = user else {
//            print("unwrapped_userDict failed")
//            completion(.failure(UserStoreError.failedDecode))
//            return
//        }
        completion(.success(self.arryDashboardTableObjects ?? [DashboardTableObject]()))

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
