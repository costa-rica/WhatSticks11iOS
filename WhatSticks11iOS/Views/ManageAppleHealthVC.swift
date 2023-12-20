//
//  ManageAppleHealthVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 08/12/2023.
//

import UIKit
import HealthKit

class ManageAppleHealthVC: TemplateVC {

    var userStore: UserStore!
    var requestStore: RequestStore!
    var appleHealthDataFetcher:AppleHealthDataFetcher!
    var healthDataStore: HealthDataStore!
    
    let datePicker = UIDatePicker()
    let btnGetData = UIButton()
    let btnDeleteData = UIButton()
    let lblAllHistory = UILabel()
    let swtchAllHistory = UISwitch()
    let lblDatePicker = UILabel()
    var arryStepsDict = [[String:String]](){
        didSet{
            actionGetHeartRateData()
        }
    }
    var arrySleepDict = [[String:String]](){
        didSet{
            
            let all_data_count = arrySleepDict.count + arryStepsDict.count + arryHeartRateDict.count
            if all_data_count > 0{
                print("sending \(String(all_data_count)) records")
                self.sendAppleHealthData(arryAppleHealthData: arrySleepDict + arryStepsDict + arryHeartRateDict)
            }
            else{
                self.templateAlert(alertMessage: "No records found to add. Check dates.")
            }
        }
    }
    var arryHeartRateDict = [[String:String]](){
        didSet{
            print("get haert rate")
            actionGetSleepData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Manage Apple Health"
//        self.setScreenNameFontSize(size: 20)
        print("- in ManageAppleHealthVC viewDidLoad -")

        setupAllHistorySwitch()
        setupDatePickerLabel()
        setupDatePicker()
        setup_btnGetData()
        setup_btnDeleteData()
        self.setScreenNameFontSize()
    }
    private func setupAllHistorySwitch() {
        
        swtchAllHistory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(swtchAllHistory)

        swtchAllHistory.bottomAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: -5)).isActive = true
        swtchAllHistory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive = true
        swtchAllHistory.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        lblAllHistory.text = "Get all history"
        lblAllHistory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblAllHistory)

        
        lblAllHistory.centerYAnchor.constraint(equalTo: swtchAllHistory.centerYAnchor).isActive = true
        lblAllHistory.trailingAnchor.constraint(equalTo: swtchAllHistory.leadingAnchor, constant: widthFromPct(percent: -2)).isActive = true
        
        
    }
    private func setupDatePickerLabel() {
        lblDatePicker.text = "Get all history beginning from:"
        lblDatePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblDatePicker)

        lblDatePicker.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: 15)).isActive = true
        lblDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)

        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.topAnchor.constraint(equalTo: lblDatePicker.bottomAnchor, constant: heightFromPct(percent: 2)).isActive = true
    }
    private func setup_btnGetData() {
        btnGetData.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnGetData)
        btnGetData.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnGetData.addTarget(self, action: #selector(actionGetData), for: .touchUpInside)
        btnGetData.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        btnGetData.trailingAnchor.constraint(equalTo: vwFooter.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        btnGetData.backgroundColor = .systemBlue
        btnGetData.layer.cornerRadius = 10
        btnGetData.setTitle(" Add Data ", for: .normal)
    }
    private func setup_btnDeleteData() {
        btnDeleteData.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnDeleteData)
        btnDeleteData.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnDeleteData.addTarget(self, action: #selector(alertDeleteConfirmation), for: .touchUpInside)
        btnDeleteData.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        btnDeleteData.leadingAnchor.constraint(equalTo: vwFooter.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        btnDeleteData.backgroundColor = .systemOrange
        btnDeleteData.layer.cornerRadius = 10
        btnDeleteData.setTitle(" Delete Data ", for: .normal)
    }
    @objc func switchChanged(mySwitch: UISwitch) {
        let isOn = mySwitch.isOn
        datePicker.isHidden = isOn
        lblDatePicker.isHidden = isOn
    }
    @objc func actionGetData() {
        self.showSpinner()
        if swtchAllHistory.isOn {
            self.appleHealthDataFetcher.fetchStepsAndOtherQuantityType(quantityTypeIdentifier: .stepCount) { arryStepsDict in
                self.arryStepsDict = arryStepsDict
            }
        } else {
            self.appleHealthDataFetcher.fetchStepsAndOtherQuantityType(quantityTypeIdentifier: .stepCount, startDate: self.datePicker.date) { arryStepsDict in
                self.arryStepsDict = arryStepsDict
            }
        }
    }
    func actionGetSleepData(){
        if swtchAllHistory.isOn {
            self.appleHealthDataFetcher.fetchSleepData(categoryTypeIdentifier:.sleepAnalysis) { arrySleepDict in
                self.arrySleepDict = arrySleepDict
            }
        } else {
            self.appleHealthDataFetcher.fetchSleepData(categoryTypeIdentifier: .sleepAnalysis, startDate: self.datePicker.date) { arrySleepDict in
                self.arrySleepDict = arrySleepDict
            }
        }
    }
    func actionGetHeartRateData(){
        if swtchAllHistory.isOn {
            self.appleHealthDataFetcher.fetchStepsAndOtherQuantityType(quantityTypeIdentifier: .heartRate) { arryHeartRateDict in
                self.arryHeartRateDict = arryHeartRateDict
            }
        } else {
            self.appleHealthDataFetcher.fetchStepsAndOtherQuantityType(quantityTypeIdentifier: .heartRate, startDate: self.datePicker.date) { arryHeartRateDict in
                self.arryHeartRateDict = arryHeartRateDict
            }
        }
    }
    // This function could be called when you want to show the delete confirmation
    @objc func alertDeleteConfirmation() {
        let alertController = UIAlertController(title: "Are you sure you want to delete?", message: "This will only delete Apple Health Data from What Sticks Databases. Your Apple Health Data remain be unaffected.", preferredStyle: .alert)
        // 'Yes' action
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // Handle the 'Yes' action here
            self?.showSpinner()
            self?.deleteAppleHealthData()
        }
        // 'No' action
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        // Adding actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        // Presenting the alert
        present(alertController, animated: true, completion: nil)
    }
    func sendAppleHealthData(arryAppleHealthData: [[String:String]]){
        self.healthDataStore.callRecieveAppleHealthData(arryAppleHealthData: arryAppleHealthData) { responseResult in
            self.removeSpinner()
            switch responseResult{
            case let .success(responseDict):
                

                
                if let unwp_count_of_user_apple_health_records = responseDict["count_of_user_apple_health_records"]{
                    
                    self.templateAlert(alertTitle: "Success", alertMessage: "Added \(responseDict["count_of_added_records"] ?? "<failed to get count_of_added_records key from response> ") records")
                    
                    
                    for obj in self.userStore.arryDataSourceObjects!{
                        if obj.name == "Apple Health Data"{
                            print("** unwp_count_of_entries: \(unwp_count_of_user_apple_health_records)")
                            obj.recordCount = unwp_count_of_user_apple_health_records
//                            self.userStore.writeDataSourceJson()
                            self.userStore.writeObjectToJsonFile(object: self.userStore.arryDataSourceObjects, filename: "arryDataSourceObjects.json")
                        }
                    }
                }
                else{
                    print("sent to processing")
                    self.templateAlert(alertTitle: "Processing Data", alertMessage:  responseDict["alertMessage"] ?? "<failed to get good message>")
                }
                
            case let .failure(error):
                self.templateAlert(alertMessage: "Failed to upload data. Error: \(error)")
            }
        }
    }
    func deleteAppleHealthData(){
        self.healthDataStore.callDeleteAppleHealthData { responseResult in
            switch responseResult{
            case .success(_):
                if let unwp_arryDashHealthDataObj = self.userStore.arryDataSourceObjects{
                    for obj in unwp_arryDashHealthDataObj{
                        if obj.name == "Apple Health Data"{
                            obj.recordCount = "0"
//                            self.userStore.writeDataSourceJson()
                            self.userStore.writeObjectToJsonFile(object: self.userStore.arryDataSourceObjects, filename: "arryDataSourceObjects.json")
                        }
                    }
                }
                self.userStore.deleteJsonFile(filename: "arryDashboardTableObjects.json")
                if let _ = self.userStore.arryDashboardTableObjects{
                    self.userStore.arryDashboardTableObjects!.removeAll { $0.sourceDataOfDepVar=="Apple Health Data" }

                }
                
                self.removeSpinner()
                self.templateAlert(alertMessage: "Delete successful!")
            case .failure(_):
                self.removeSpinner()
                self.templateAlert(alertTitle: "Failed to delete", alertMessage: "Could be anything...")
            }
        }
    }
    
}

