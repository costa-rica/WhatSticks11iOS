//
//  HealthDataStore.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 08/12/2023.
//

import Foundation

enum HealthDataStoreError: Error {
    case noServerResponse
    case unknownServerResponse
    case failedToDeleteUser
    
    var localizedDescription: String {
        switch self {
        case .noServerResponse: return "What Sticks API main server is not responding."
        case .unknownServerResponse: return "Server responded but What Sticks iOS has no way of handling response."

        default: return "What Sticks main server is not responding."
            
        }
    }
}

class HealthDataStore {
//    var user:User!
    var requestStore:RequestStore!
    
//    func callRecieveAppleHealthData(arryAppleHealthData:[[String:String]], completion: @escaping (Result<[String: String], Error>) -> Void) {
    func callReceiveAppleHealthData(dateStringTimeStamp: String, lastChunk: String, arryAppleHealthData: [AppleHealthQuantityCategory], completion: @escaping (Result<[String: String], Error>) -> Void) {
        print("- in callRecieveAppleHealthData")
        let receiveAppleHealthObject = RecieveAppleHealthObject()
//        receiveAppleHealthObject.filename = filename
        receiveAppleHealthObject.dateStringTimeStamp = dateStringTimeStamp
        receiveAppleHealthObject.last_chunk = lastChunk
        receiveAppleHealthObject.arryAppleHealthQuantityCategory = arryAppleHealthData
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .receive_apple_qty_cat_data, body: receiveAppleHealthObject)
        let task = requestStore.session.dataTask(with: request) { data, response, error in
            // Handle potential error from the data task
            if let error = error {
                print("HealthDataStore.callRecieveAppleHealthData received an error. Error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let unwrapped_data = data else {
                // No data scenario
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                    print("HealthDataStore.callRecieveAppleHealthData received unexpected json response from WSAPI. URLError(.badServerResponse): \(URLError(.badServerResponse))")
                }
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
                    
                    DispatchQueue.main.async {
                        completion(.success(jsonResult))
                    }
                } else {
                    // Data is not in the expected format
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                        print("HealthDataStore.callRecieveAppleHealthData received unexpected json response from WSAPI. URLError(.cannotParseResponse): \(URLError(.cannotParseResponse))")
                    }
                }
            } catch {
                // Data parsing error
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("HealthDataStore.callRecieveAppleHealthData produced an error while parsing. Error: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func callReceiveAppleWorkoutsData(userId: String,dateStringTimeStamp:String, arryAppleWorkouts:[AppleHealthWorkout], completion: @escaping(Result<[String:String],Error>) -> Void){
        
        print("- in callReceiveAppleWorkoutsData -")
        
//        let filename = "AppleWorkouts-user_id\(userId)-\(dateStringTimeStamp).json"
//        print("filename: \(filename)")
        
        let receiveAppleWorkoutObject = RecieveAppleWorkout()
//        receiveAppleWorkoutObject.filename = filename
        receiveAppleWorkoutObject.dateStringTimeStamp = dateStringTimeStamp
        receiveAppleWorkoutObject.arryAppleHealthWorkout = arryAppleWorkouts
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .receive_apple_workouts_data, body: receiveAppleWorkoutObject)
        
        let task = requestStore.session.dataTask(with: request) { data, response, error in
            print("task sent")
            // Handle potential error from the data task
            if let error = error {
                print("HealthDataStore.callRecieveAppleHealthData received an error. Error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let unwrapped_data = data else {
                // No data scenario
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                    print("HealthDataStore.callRecieveAppleHealthData received unexpected json response from WSAPI. URLError(.badServerResponse): \(URLError(.badServerResponse))")
                }
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
                    
                    DispatchQueue.main.async {
                        completion(.success(jsonResult))
                    }
                } else {
                    // Data is not in the expected format
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                        print("HealthDataStore.callRecieveAppleHealthData received unexpected json response from WSAPI. URLError(.cannotParseResponse): \(URLError(.cannotParseResponse))")
                    }
                }
            } catch {
                // Data parsing error
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("HealthDataStore.callRecieveAppleHealthData produced an error while parsing. Error: \(error)")
                }
            }
        }
        task.resume()
    }
    
    
    
}

extension HealthDataStore {
    func callDeleteAppleHealthData(completion: @escaping (Result<[String: String], Error>) -> Void) {
        print("- in callDeleteAppleHealthData")
        let request = requestStore.createRequestWithToken(endpoint: .delete_apple_health_for_user)
        let task = requestStore.session.dataTask(with: request) { data, response, error in
            // Handle potential error from the data task
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let unwrapped_data = data else {
                // No data scenario
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
                    DispatchQueue.main.async {
                        completion(.success(jsonResult))
                    }
                } else {
                    // Data is not in the expected format
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                    }
                }
            } catch {
                // Data parsing error
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    func sendChunksToWSAPI(userId: String, dateStringTimeStamp:String, arryAppleHealthData: [AppleHealthQuantityCategory], chunkSize: Int = 200000, completion: @escaping (Result<[String: String], Error>) -> Void) {
        print("- accessed HealthDataStore.sendChunksToWSAPI")

//        let filename = "AppleHealthQuantityCategory-user_id\(userId)-\(dateStringTimeStamp).json"

        let totalChunks = arryAppleHealthData.count / chunkSize + (arryAppleHealthData.count % chunkSize == 0 ? 0 : 1)
        // Understanding totalChunks calculation:
        // a) `%` is modulus operator;
        // b) `== 0 ? 0 : 1` --> this part is a ternary conditional, saying if modulus is not 0 make parentheses a 1, thereby adding another chunk.
        var currentChunkIndex = 0
        var totalAddedRecords = 0
        var finalResponse: [String: String] = [:]
        func sendNextChunk() {
            guard currentChunkIndex < totalChunks else {
                print("Sent final chunk")
                completion(.success(finalResponse))
                return
            }
            let start = currentChunkIndex * chunkSize
            let end = start + chunkSize
            let chunk = Array(arryAppleHealthData[start..<min(end, arryAppleHealthData.count)])
            currentChunkIndex += 1
            let lastChunk = currentChunkIndex >= totalChunks ? "True" : "False"
            callReceiveAppleHealthData(dateStringTimeStamp: dateStringTimeStamp, lastChunk: lastChunk, arryAppleHealthData: chunk) { result in
                print("sendNextChunk: \(currentChunkIndex)")
                switch result {
                case .success(let response):
                    finalResponse = response
                    if let addedCountStr = response["count_of_added_records"], let addedCount = Int(addedCountStr) {
                        totalAddedRecords += addedCount
                    }
                    if let userAppleHealthCount = response["count_of_user_apple_health_records"] {
                        finalResponse["count_of_user_apple_health_records"] = userAppleHealthCount
                    }
                    sendNextChunk()

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        // First "loop"
        sendNextChunk()
    }
}
