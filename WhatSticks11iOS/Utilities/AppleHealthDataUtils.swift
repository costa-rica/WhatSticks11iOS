//
//  AppleHealthDataUtils.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 08/12/2023.
//

import Foundation
import HealthKit

enum HealthDataFetcherError: Error {
    case invalidQuantityType
    case fetchingError
    case unknownError
    case sleepAnalysisNotAvailible
    case unauthorizedAccess
    
    var localizedDescription: String {
        switch self {
        case .invalidQuantityType: return "HealthDataFetcherError."

        default: return "idk ... ¯\\_(ツ)_/¯ ... HealthDataFetcherError."
            
        }
    }
}

class AppleHealthDataFetcher {
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit() {
        // Specify the data types you want to read
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            if success {
                print("-- User allowed Read Health data")
            } else {
                // Handle the error here.
                print("Authorization failed with error: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    // steps history
//    func fetchStepsAndOtherQuantityType(quantityTypeIdentifier: HKQuantityTypeIdentifier, startDate: Date? = nil, completion: @escaping ([[String: String]]) -> Void) {
    func fetchStepsAndOtherQuantityType(quantityTypeIdentifier: HKQuantityTypeIdentifier, startDate: Date? = nil, completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        print("- accessed fetchStepsAndOtherQuantityType, fetching \(quantityTypeIdentifier.rawValue) ")
        
        var stepsEntries = [[String: String]]()
        // Assuming endDate is the current date
        let endDate = Date()
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            print("Invalid quantity type")
            completion(.failure(HealthDataFetcherError.invalidQuantityType))
            return
        }
        let predicate: NSPredicate
        if let startDate = startDate {
            predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        } else {
            // If startDate is nil, the predicate will not filter based on the start date
            predicate = HKQuery.predicateForSamples(withStart: nil, end: endDate, options: .strictEndDate)
        }
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async{
                if let error = error{
                    print("Error making query: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                samples?.forEach { sample in
                    if let sample = sample as? HKQuantitySample {
                        var entry: [String: String] = [:]
                        entry["sampleType"] = sample.sampleType.identifier
                        entry["startDate"] = sample.startDate.description
                        entry["endDate"] = sample.endDate.description
                        entry["metadata"] = sample.metadata?.description ?? "No Metadata"
                        entry["sourceName"] = sample.sourceRevision.source.name
                        entry["sourceVersion"] = sample.sourceRevision.version
                        entry["sourceProductType"] = sample.sourceRevision.productType ?? "Unknown"
                        entry["device"] = sample.device?.name ?? "Unknown Device"
                        entry["UUID"] = sample.uuid.uuidString
                        if quantityTypeIdentifier == .stepCount{
                            entry["quantity"] = String(sample.quantity.doubleValue(for: HKUnit.count()))
                        } else if quantityTypeIdentifier == .heartRate {
                            let unit = quantityTypeIdentifier == .heartRate ? HKUnit(from: "count/min") : HKUnit.count()
                            entry["quantity"] = String(sample.quantity.doubleValue(for: unit))
                        }
                        stepsEntries.append(entry)
                    }
                }
                completion(.success(stepsEntries))
                print("\(quantityTypeIdentifier.rawValue) count: \(stepsEntries.count)")
            }
        }
        healthStore.execute(query)
    }
    
    // All Sleep data
//    func fetchSleepData(categoryTypeIdentifier: HKCategoryTypeIdentifier, startDate: Date? = nil, completion: @escaping ([[String: String]]) -> Void) {
    func fetchSleepDataAndOtherCategoryType(categoryTypeIdentifier:HKCategoryTypeIdentifier, startDate: Date? = nil, completion:@escaping(Result<[[String:String]],Error>) -> Void){
        print("- accessed fetchSleepDataAndOtherCategoryType, fetching \(categoryTypeIdentifier.rawValue) ")
        var sleepEntries = [[String: String]]()

        // Check for authorization
        let authorizationStatus = healthStore.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: categoryTypeIdentifier)!)
        guard authorizationStatus == .sharingAuthorized else {
            print("Unauthorized access to sleep analysis data")
            completion(.failure(HealthDataFetcherError.unauthorizedAccess))
            return
        }
        
        
        // Assuming endDate is the current date
        let endDate = Date()
        
//        guard let sleepType = HKObjectType.categoryType(forIdentifier: categoryTypeIdentifier) else {
//            print("Sleep Analysis type not available")
//            completion(.failure(HealthDataFetcherError.sleepAnalysisNotAvailible))
//            return
//        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: categoryTypeIdentifier) else {
            print("Sleep Analysis type not available")
            completion(.failure(HealthDataFetcherError.sleepAnalysisNotAvailible))
            return
        }
        
        
        
        let predicate: NSPredicate
        if let startDate = startDate {
            predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        } else {
            // If startDate is nil, the predicate will not filter based on the start date
            predicate = HKQuery.predicateForSamples(withStart: nil, end: endDate, options: .strictEndDate)
        }

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async{
                if let error = error {
                    print("Error making query: \(error.localizedDescription )")
                    completion(.failure(error))
                }
                
                samples?.forEach { sample in
                    if let sample = sample as? HKCategorySample {
                        var entry: [String: String] = [:]
                        entry["sampleType"] = sample.sampleType.identifier
                        entry["startDate"] = sample.startDate.description
                        entry["endDate"] = sample.endDate.description
                        entry["value"] = String(sample.value)
                        entry["metadata"] = sample.metadata?.description ?? "No Metadata"
                        entry["sourceName"] = sample.sourceRevision.source.name
                        entry["sourceVersion"] = sample.sourceRevision.version ?? "Unknown"
                        entry["sourceProductType"] = sample.sourceRevision.productType ?? "Unknown"
                        entry["device"] = sample.device?.name ?? "Unknown Device"
                        entry["UUID"] = sample.uuid.uuidString
                        sleepEntries.append(entry)
                    }
                }
                completion(.success(sleepEntries))
//                print("sleepEntries count: \(sleepEntries.count)")
                print("\(categoryTypeIdentifier.rawValue) count: \(sleepEntries.count)")
            }
        }
        healthStore.execute(query)
    }
}
