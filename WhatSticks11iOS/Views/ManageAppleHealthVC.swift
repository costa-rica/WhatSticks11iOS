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
    var criticalDataFlag=true
    
    let datePicker = UIDatePicker()
    let lblDatePicker = UILabel()
    let lblAllHistory = UILabel()
    let swtchAllHistory = UISwitch()
    var swtchAllHistoryIsOn = false
    var dtUserHistory:Date?
    let btnGetData = UIButton()
    let btnDeleteData = UIButton()
    var arryStepsDict = [AppleHealthQuantityCategory](){
        didSet{
//            print("- in arryStepsDict didSet")
            actionGetSleepData()
        }
    }
    var arrySleepDict = [AppleHealthQuantityCategory](){
        didSet{
//            print("- in arrySleepDict didSet")
            actionGetHeartRateData()
        }
    }
    var arryHeartRateDict = [AppleHealthQuantityCategory](){
        didSet{
//            print("- in arryHeartRateDict didSet")
            necessaryDataCollected()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupIsDev(urlStore: requestStore.urlStore)
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Manage Apple Health"
        self.appleHealthDataFetcher.authorizeHealthKit()
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
        btnGetData.addTarget(self, action: #selector(actionGetStepsData), for: .touchUpInside)
        btnGetData.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        btnGetData.trailingAnchor.constraint(equalTo: vwFooter.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        btnGetData.backgroundColor = .systemBlue
        btnGetData.layer.cornerRadius = 10
        btnGetData.setTitle(" Add Data ", for: .normal)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        swtchAllHistoryIsOn = mySwitch.isOn
        datePicker.isHidden = swtchAllHistoryIsOn
        lblDatePicker.isHidden = swtchAllHistoryIsOn
        print("swtchAllHistoryIsOn: \(swtchAllHistoryIsOn)")
    }
    
    
    @objc func actionGetStepsData() {
        if swtchAllHistoryIsOn {
            dtUserHistory = nil
        } else {
            dtUserHistory = datePicker.date
        }
        self.showSpinner()
            self.appleHealthDataFetcher.fetchStepsAndOtherQuantityType(quantityTypeIdentifier: .stepCount, startDate: self.dtUserHistory) { fetcherResult in
                switch fetcherResult{
                case let .success(arryStepsDict):
                    print("succesfully collected - arryStepsDict - from healthFetcher class")
                    self.arryStepsDict = arryStepsDict
                    if arryStepsDict.count == 0 {
                        self.templateAlert(alertMessage: "Either you did not allow permissions of there is no STEPS data in your Apple Health Data.\n Go to Settings > Health > Data Access & Devices > WhatSticks11iOS to grant access.")
                        self.removeSpinner()
                    }
                case let .failure(error):
                    self.templateAlert(alertTitle: "Alert", alertMessage: "This app will not function correctly without steps data. Go to Settings > Health > Data Access & Devices > WhatSticks11iOS to grant access")
                    print("There was an error getting steps: \(error)")
                    self.removeSpinner()
                }
            }
        }
    func actionGetSleepData(){
            self.appleHealthDataFetcher.fetchSleepDataAndOtherCategoryType(categoryTypeIdentifier:.sleepAnalysis, startDate: self.dtUserHistory) { fetcherResult in
                switch fetcherResult{
                case let .success(arrySleepDict):
                    print("succesfully collected - arrySleepDict - from healthFetcher class")
                    self.arrySleepDict = arrySleepDict
                    if arrySleepDict.count == 0 {
                        self.templateAlert(alertMessage: "Either you did not allow permissions of there is no SLEEP data in your Apple Health Data.\n Go to Settings > Health > Data Access & Devices > WhatSticks11iOS to grant access.")
                        self.removeSpinner()
                    }
                case let .failure(error):
                    self.templateAlert(alertTitle: "Alert", alertMessage: "This app will not function correctly without sleep data. Go to Settings > Health > Data Access & Devices > WhatSticks11iOS to grant access")
                    print("There was an error getting sleep: \(error)")
                    self.removeSpinner()
                
            }
        }
    }
    func actionGetHeartRateData(){
            self.appleHealthDataFetcher.fetchStepsAndOtherQuantityType(quantityTypeIdentifier: .heartRate, startDate: self.dtUserHistory) { fetcherResult in
                switch fetcherResult{
                case let .success(arryHeartRateDict):
                    print("succesfully collected - arryHeartRateDict - from healthFetcher class")
                    self.arryHeartRateDict = arryHeartRateDict
                case let .failure(error):
                    print("There was an error getting heart rate: \(error)")
                    self.removeSpinner()
            }
            }
    }
    func necessaryDataCollected(){
        let all_data_count = arrySleepDict.count + arryStepsDict.count + arryHeartRateDict.count
        if all_data_count > 0{
            print("sending (arrySleepDict + arryStepsDict + arryHeartRateDict): \(String(all_data_count)) records")
            self.sendAppleHealthData(arryAppleHealthData: arrySleepDict + arryStepsDict + arryHeartRateDict)
        }
        else{
            self.templateAlert(alertMessage: "No records found to add. Check dates.")
        }
    }
    func sendAppleHealthData(arryAppleHealthData: [AppleHealthQuantityCategory]){
        print("- in sendAppleHealthData")
        guard let user_id = userStore.user.id else {
            self.templateAlert(alertMessage: "No user id. check ManageAppleHealthVC sendAppleHealthData.")
            return}
        self.healthDataStore.sendChunksToWSAPI(userId:user_id ,arryAppleHealthData: arryAppleHealthData) { responseResult in
            self.removeSpinner()
            switch responseResult{
            case let .success(responseDict):
                if let unwp_count_of_user_apple_health_records = responseDict["count_of_user_apple_health_records"]{
                    
                    self.templateAlert(alertTitle: "Success", alertMessage: "Added \(responseDict["count_of_added_records"] ?? "<failed to get count_of_added_records key from response> ") records")
                    for obj in self.userStore.arryDataSourceObjects!{
                        if obj.name == "Apple Health Data"{
                            print("** unwp_count_of_entries: \(unwp_count_of_user_apple_health_records)")
                            obj.recordCount = unwp_count_of_user_apple_health_records
                            self.userStore.writeObjectToJsonFile(object: self.userStore.arryDataSourceObjects, filename: "arryDataSourceObjects.json")
                        }
                    }
                }
                else{
                    print("sent to processing")
                    print("responseDict:::: ")
                    print(responseDict)
                    print("-------------------")
                    self.templateAlert(alertTitle: "Processing Data", alertMessage:  responseDict["alertMessage"] ?? "<failed to get good message>")
                }
            case let .failure(error):
                self.templateAlert(alertMessage: "Failed to upload data. Error: \(error)")
            }
        }
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

