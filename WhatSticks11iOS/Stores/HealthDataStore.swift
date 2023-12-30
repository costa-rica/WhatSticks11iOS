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
    func callRecieveAppleHealthData(filename: String, lastChunk: String, arryAppleHealthData: [AppleHealthQuantityCategory], completion: @escaping (Result<[String: String], Error>) -> Void) {
        print("- in callRecieveAppleHealthData")
//        let requestBody: [String: Any] = [
//            "filename": filename,
//            "last_chunk": lastChunk,
//            "arryAppleHealthData": arryAppleHealthData
//        ]
        var receiveAppleHealthObject = RecieveAppleHealthObject()
        receiveAppleHealthObject.filename = filename
        receiveAppleHealthObject.last_chunk = lastChunk
        receiveAppleHealthObject.arryAppleHealthQuantityCategory = arryAppleHealthData
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .receive_apple_health_data, body: receiveAppleHealthObject)
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
}

extension HealthDataStore {
    
    func sendChunksToWSAPI(userId: String, arryAppleHealthData: [AppleHealthQuantityCategory], chunkSize: Int = 200000, completion: @escaping (Result<[String: String], Error>) -> Void) {
        print("- accessed HealthDataStore.sendChunksToWSAPI")
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        // Set the date format
        dateFormatter.dateFormat = "yyyyMMdd-HHmm"
        // Get the date string
        let dateString = dateFormatter.string(from: currentDate)
        let filename = "AppleHealthQuantityCategory-user_id\(userId)-\(dateString).json"

        let totalChunks = arryAppleHealthData.count / chunkSize + (arryAppleHealthData.count % chunkSize == 0 ? 0 : 1)
        var currentChunkIndex = 0
        var totalAddedRecords = 0
        var finalResponse: [String: String] = [:]

        func sendNextChunk() {
            print("sendNextChunk ")
            guard currentChunkIndex < totalChunks else {
//                finalResponse["count_of_added_records"] = String(totalAddedRecords)
                print("final response: \(finalResponse)")
                completion(.success(finalResponse))
                return
            }

            let start = currentChunkIndex * chunkSize
            let end = start + chunkSize
            let chunk = Array(arryAppleHealthData[start..<min(end, arryAppleHealthData.count)])
            currentChunkIndex += 1
            let lastChunk = currentChunkIndex >= totalChunks ? "True" : "False"
            callRecieveAppleHealthData(filename: filename, lastChunk: lastChunk, arryAppleHealthData: chunk) { result in
                switch result {
                case .success(let response):
                    finalResponse = response
                    // MARK: Need to adapt to a different response The response should just be continue
                    if let addedCountStr = response["count_of_added_records"], let addedCount = Int(addedCountStr) {
                        totalAddedRecords += addedCount
                    }
                    if let userAppleHealthCount = response["count_of_user_apple_health_records"] {
                        finalResponse["count_of_user_apple_health_records"] = userAppleHealthCount
                    }
                    sendNextChunk()
//                    if let keep_going = response["chunk_response"]{
//                        sendNextChunk()
//                    }

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        sendNextChunk()
    }
}
