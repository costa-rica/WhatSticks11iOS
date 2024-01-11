//
//  DashboardHealthDataObject.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 06/12/2023.
//

import Foundation


class DataSourceObject: Codable{
    var name:String?//name for display on ManageDataVC
    var recordCount:String?
    var earliestRecordDate:String?
}

class DashboardTableObject:Codable{
    var dependentVarName:String?// name for display at the top of DashboardVC (i.e. sleep time dashboard)
    var sourceDataOfDepVar:String?// This is used in delete, but also in general to loop through userStore.arryDashboardTableObj and find all "Apple Health" or "Oura Ring"
    var arryIndepVarObjects:[IndepVarObject]?
    var definition:String?
    var verb:String?
}

class IndepVarObject:Codable{
    var independentVarName:String?// name for display in each row of DashboardVC (i.e. steps count, heart rate, etc.,)
    var forDepVarName:String?// i.e. sleep time dashboard
    var correlationValue:String?
    var correlationObservationCount:String?
    var definition:String?
    var noun:String?
}

class RecieveAppleHealthObject:Codable{
//    var filename:String?
    var dateStringTimeStamp: String?
    var last_chunk:String?
    var arryAppleHealthQuantityCategory:[AppleHealthQuantityCategory]?
}

class AppleHealthQuantityCategory:Codable{
    var sampleType:String?
    var startDate:String?
    var endDate:String?
    var value:String?
    var metadata:String?
    var sourceName:String?
    var sourceVersion:String?
    var sourceProductType:String?
    var device:String?
    var UUID:String?
    var quantity:String?
}

class RecieveAppleWorkout:Codable{
//    var filename:String?
    var dateStringTimeStamp: String?
    var arryAppleHealthWorkout:[AppleHealthWorkout]?
}

class AppleHealthWorkout:Codable{
    var sampleType:String?
    var startDate:String?
    var endDate:String?
    var duration:String?
    var totalEnergyBurned:String?
    var totalDistance:String?
    var sourceName:String?
    var sourceVersion:String?
    var device:String?
    var UUID:String?
}
