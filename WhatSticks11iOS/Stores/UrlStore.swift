//
//  UrlStore.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 06/12/2023.
//

import UIKit

enum APIBase:String, CaseIterable {
    case local = "localhost"
    case dev = "dev"
    case prod = "prod"
    var urlString:String {
        switch self{
        case .local: return "http://127.0.0.1:5001/"
        case .dev: return "https://api10.what-sticks.com/"
        case .prod: return "https://api10.what-sticks.com/"
        }
    }
}

enum EndPoint: String {
    case are_we_running = "are_we_running"
    case user = "user"
    case register = "register"
    case login = "login"
    case delete_user = "delete_user"
    case send_data_source_objects = "send_data_source_objects"
    case send_dashboard_table_objects = "send_dashboard_table_objects"
    case receive_apple_health_data = "receive_apple_health_data"
    case delete_apple_health_for_user = "delete_apple_health_for_user"
    case add_oura_token = "add_oura_token"
    case add_oura_sleep_sessions = "add_oura_sleep_sessions"
}

class URLStore {

    var apiBase:APIBase!

    func callEndpoint(endPoint: EndPoint) -> URL{
        let baseURLString = apiBase.urlString + endPoint.rawValue
        let components = URLComponents(string:baseURLString)!
        return components.url!
    }
}
