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
    case typeNotFound
    
    var localizedDescription: String {
        switch self {
        case .invalidQuantityType: return "HealthDataFetcherError."
        case .typeNotFound: return "One of your Apple Health Data was not found"
        default: return "idk ... ¯\\_(ツ)_/¯ ... HealthDataFetcherError."
        }
    }
}

class AppleHealthDataFetcher {
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit() {
        print("AppleHealthDataFetcher.authorizeHealthKit ---> requesting access ")
        // Specify the data types you want to read
        let sampleTypesToRead = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        ])
        
        healthStore.requestAuthorization(toShare: nil, read: sampleTypesToRead) { (success, error) in
            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
        }

    }

    
    
    
    func fetchStepsAndOtherQuantityType(quantityTypeIdentifier: HKQuantityTypeIdentifier, startDate: Date? = nil, completion: @escaping (Result<[AppleHealthQuantityCategory], Error>) -> Void) {
        print("- accessed fetchStepsAndOtherQuantityType, fetching \(quantityTypeIdentifier.rawValue) ")
        
        var stepsEntries = [AppleHealthQuantityCategory]() // Array of AppleHealthQuantityCategory
        // Assuming endDate is the current date
        let endDate = Date()
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            print("Invalid quantity type")
            completion(.failure(HealthDataFetcherError.typeNotFound))
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
            DispatchQueue.main.async {
                if let error = error {
                    print("Error making query: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                samples?.forEach { sample in
                    if let sample = sample as? HKQuantitySample {
                        let entry = AppleHealthQuantityCategory()
                        entry.sampleType = sample.sampleType.identifier
                        entry.startDate = sample.startDate.description
                        entry.endDate = sample.endDate.description
                        entry.metadata = sample.metadata?.description ?? "No Metadata"
                        entry.sourceName = sample.sourceRevision.source.name
                        entry.sourceVersion = sample.sourceRevision.version
                        entry.sourceProductType = sample.sourceRevision.productType ?? "Unknown"
                        entry.device = sample.device?.name ?? "Unknown Device"
                        entry.UUID = sample.uuid.uuidString

                        // Setting quantity based on the type of quantity data
                        if quantityTypeIdentifier == .stepCount {
                            entry.quantity = String(sample.quantity.doubleValue(for: HKUnit.count()))
                        } else if quantityTypeIdentifier == .heartRate {
                            let unit = HKUnit(from: "count/min")
                            entry.quantity = String(sample.quantity.doubleValue(for: unit))
                        }
                        stepsEntries.append(entry)
                    }
                }
                completion(.success(stepsEntries))
                print("fetchStepsAndOtherQuantityType finished::: \(quantityTypeIdentifier.rawValue) count: \(stepsEntries.count)")
            }
        }
        healthStore.execute(query)
    }

    
    func fetchSleepDataAndOtherCategoryType(categoryTypeIdentifier: HKCategoryTypeIdentifier, startDate: Date? = nil, completion: @escaping (Result<[AppleHealthQuantityCategory], Error>) -> Void) {
        print("- accessed fetchSleepDataAndOtherCategoryType, fetching \(categoryTypeIdentifier.rawValue)")
        
        var sleepEntries = [AppleHealthQuantityCategory]() // Array of AppleHealthQuantityCategory
        // Assuming endDate is the current date
        let endDate = Date()
        
        guard let categoryType = HKObjectType.categoryType(forIdentifier: categoryTypeIdentifier) else {
            print("CategoryType (sleep) type not available ---> **** Expected when user did not allow for Sleep data ********")
            completion(.failure(HealthDataFetcherError.typeNotFound))
            return
        }

        let predicate: NSPredicate
        if let startDate = startDate {
            predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        } else {
            predicate = HKQuery.predicateForSamples(withStart: nil, end: endDate, options: .strictEndDate)
        }

        let query = HKSampleQuery(sampleType: categoryType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error making query: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                samples?.forEach { sample in
                    if let sample = sample as? HKCategorySample {
                        let entry = AppleHealthQuantityCategory()
                        entry.sampleType = sample.sampleType.identifier
                        entry.startDate = sample.startDate.description
                        entry.endDate = sample.endDate.description
                        entry.value = String(sample.value)
                        entry.metadata = sample.metadata?.description ?? "No Metadata"
                        entry.sourceName = sample.sourceRevision.source.name
                        entry.sourceVersion = sample.sourceRevision.version ?? "Unknown"
                        entry.sourceProductType = sample.sourceRevision.productType ?? "Unknown"
                        entry.device = sample.device?.name ?? "Unknown Device"
                        entry.UUID = sample.uuid.uuidString
                        sleepEntries.append(entry)
                    }
                }
                completion(.success(sleepEntries))
                print("fetchSleepDataAndOtherCategoryType finished:::: \(categoryTypeIdentifier.rawValue) count: \(sleepEntries.count)")
            }
        }
        healthStore.execute(query)
    }

    
}
