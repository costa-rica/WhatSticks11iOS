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
