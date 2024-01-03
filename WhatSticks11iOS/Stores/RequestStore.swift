//
//  RequestStore.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 06/12/2023.
//

import Foundation

enum RequestStoreError: Error{
    case encodingFailed
    case someOtherError
    var localizedDescription: String {
        switch self {
        case .encodingFailed: return "Failed to decode response."
        default: return "What Sticks main server is not responding."
        }
    }
}

class RequestStore {
    
    var urlStore:URLStore!
    var token: String!
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 240 // Timeout interval in seconds
        return URLSession(configuration: config)
    }()
    
    //MARK: for json writing/reading only
    let fileManager:FileManager
    private let documentsURL:URL
    init() {
        self.fileManager = FileManager.default
        self.documentsURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.urlStore=URLStore()
        self.urlStore.apiBase = APIBase.prod
//        self.urlStore.apiBase = APIBase.dev
    }
    
    func createRequestLogin(email:String, password:String)->Result<URLRequest,Error>{
        let url = urlStore.callEndpoint(endPoint: .login)
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        let loginString = "\(email):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return .failure(RequestStoreError.encodingFailed)
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        return .success(request)
    }
    
    func createRequestWithToken(endpoint:EndPoint) ->URLRequest{
        let url = urlStore.callEndpoint(endPoint: endpoint)
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
        print("- createRequestWithToken:")
        print(request)
        return request
    }
    
    func createRequestWithTokenAndBody<T: Encodable>(endPoint: EndPoint, body: T) -> URLRequest {
        print("- createRequestWithTokenAndBody")
        let url = urlStore.callEndpoint(endPoint: endPoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.setValue(self.token, forHTTPHeaderField: "x-access-token")
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode body: \(error)")
        }
        print("built request: \(request)")
        return request
    }
    
}
