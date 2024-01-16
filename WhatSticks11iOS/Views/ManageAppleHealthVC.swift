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
//    var criticalDataFlag=true
    let datePicker = UIDatePicker()
    let lblDatePicker = UILabel()
    let lblAllHistory = UILabel()
    let swtchAllHistory = UISwitch()
    var swtchAllHistoryIsOn = false
    var dtUserHistory:Date?
    let btnGetData = UIButton()
    var strStatusMessage=String()
    let btnDeleteData = UIButton()
    var arryStepsDict = [AppleHealthQuantityCategory](){
        didSet{
            actionGetSleepData()
        }
    }
    var arrySleepDict = [AppleHealthQuantityCategory](){
        didSet{
            actionGetHeartRateData()
        }
    }
    var arryHeartRateDict = [AppleHealthQuantityCategory](){
        didSet{
            actionGetExerciseTimeData()
        }
    }
    var arryExerciseTimeDict = [AppleHealthQuantityCategory](){
        didSet{
            //            necessaryDataCollected()
            actionGetWorkoutData()
        }
    }
    var arryWorkoutDict = [AppleHealthWorkout](){
        didSet{
//            necessaryDataCollected()
            sendAppleWorkouts()
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
    
}

/* Sending Apple Health Data */
extension ManageAppleHealthVC{
    @objc func actionGetStepsData() {

        let calendar = Calendar.current
        // Strip off time components from both dates
        let selectedDate = calendar.startOfDay(for: datePicker.date)
        let currentDate = calendar.startOfDay(for: Date())
        // Check if selectedDate is today or in the future
        if selectedDate >= currentDate {
            self.templateAlert(alertMessage: "You must pick a day in the past.")
            return
        }
        
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
                let formatted_arryStepsDictCount = formatWithCommas(number: arryStepsDict.count)
                self.spinnerScreenLblMessage(message: "Retrieved \(formatted_arryStepsDictCount) Steps records")
//                if arryStepsDict.count == 0 {
//                    self.templateAlert(alertMessage: "There are no STEPS data in your Apple Health Data")
//                    self.removeSpinner()
//                }
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
                let formatted_arrySleepDictCount = formatWithCommas(number: arrySleepDict.count)
                if let unwp_message = self.lblMessage.text {
                    self.lblMessage.text = unwp_message + "," + "\n \(formatted_arrySleepDictCount) Sleep records"
                }
//                if arrySleepDict.count == 0 {
//                    self.templateAlert(alertMessage: "There are no SLEEP data in your Apple Health Data.")
//                    self.removeSpinner()
//                }
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
                let formatted_arryHeartRateDictCount = formatWithCommas(number: arryHeartRateDict.count)
                if let unwp_message = self.lblMessage.text {
                    self.lblMessage.text = unwp_message + "," + "\n \(formatted_arryHeartRateDictCount) Heart Rate records"
                }
            case let .failure(error):
                print("There was an error getting heart rate: \(error)")
                self.removeSpinner()
            }
        }
    }
    func actionGetExerciseTimeData(){
        self.appleHealthDataFetcher.fetchStepsAndOtherQuantityType(quantityTypeIdentifier: .appleExerciseTime, startDate: self.dtUserHistory) { fetcherResult in
            switch fetcherResult{
            case let .success(arryExerciseTimeDict):
                print("succesfully collected - arryExerciseTimeDict - from healthFetcher class")
                self.arryExerciseTimeDict = arryExerciseTimeDict
//                self.removeLblMessage()
                let formatted_arryExerciseTimeDictCount = formatWithCommas(number: arryExerciseTimeDict.count)
//                self.spinnerScreenLblMessage(message: "Retrieved \(formatted_arryExerciseTimeDictCount) Exercise Time records")
                if let unwp_message = self.lblMessage.text {
                    self.lblMessage.text = unwp_message + "," + "\n \(formatted_arryExerciseTimeDictCount) Exerciese records"
                }
            case let .failure(error):
                print("There was an error getting heart rate: \(error)")
                self.removeSpinner()
            }
        }
    }
    func actionGetWorkoutData(){
        self.appleHealthDataFetcher.fetchWorkoutData( startDate: self.dtUserHistory) { fetcherResult in
            switch fetcherResult{
            case let .success(arryWorkoutDict):
                print("succesfully collected - arryWorkoutDict - from healthFetcher class")
                self.arryWorkoutDict = arryWorkoutDict
//                self.removeLblMessage()
                let formatted_arryWorkoutDictCount = formatWithCommas(number: arryWorkoutDict.count)
//                self.spinnerScreenLblMessage(message: "Retrieved \(formatted_arryWorkoutDictCount) Workout records")
                if let unwp_message = self.lblMessage.text {
                    self.lblMessage.text = unwp_message + "," + "\n \(formatted_arryWorkoutDictCount) Workout records"
                }
            case let .failure(error):
                print("There was an error getting heart rate: \(error)")
                self.removeSpinner()
            }
        }
    }
    

    func sendAppleWorkouts(){
        
        print("- in sendAppleWorkouts")
        let dateStringTimeStamp = timeStampsForFileNames()
        // dateStringTimeStamp --> important for file name used by WSAPI/WSAS
        guard let user_id = userStore.user.id else {
            self.templateAlert(alertMessage: "No user id. check ManageAppleHealthVC sendAppleHealthData.")
            return}
        let qty_cat_and_workouts_count = arrySleepDict.count + arryStepsDict.count + arryHeartRateDict.count + arryExerciseTimeDict.count + arryWorkoutDict.count
        if qty_cat_and_workouts_count > 0 {
            self.removeLblMessage()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let formatted_qty_cat_and_workouts_count = formatWithCommas(number: qty_cat_and_workouts_count)
                self.spinnerScreenLblMessage(message: "Sending Apple Health \(formatted_qty_cat_and_workouts_count) records to \nWhat Sticks API")
            }
        }
            self.healthDataStore.callReceiveAppleWorkoutsData(userId: user_id,dateStringTimeStamp:dateStringTimeStamp, arryAppleWorkouts: arryWorkoutDict) { resultResponse in
                switch resultResponse{
                case .success(_):
                    self.sendAppleHealthData(userMessage:"updated apple workouts", dateStringTimeStamp:dateStringTimeStamp)
                    self.strStatusMessage = "1) Workouts sent succesfully"
                case .failure(_):
                    self.strStatusMessage = "1) Workouts NOT sent successfully"
                    self.sendAppleHealthData(userMessage:"updated apple workouts", dateStringTimeStamp:dateStringTimeStamp)
                }
            }
        
    }
    func sendAppleHealthData(userMessage:String, dateStringTimeStamp:String){
        print("- in sendAppleHealthData")
        guard let user_id = userStore.user.id else {
            self.templateAlert(alertMessage: "No user id. check ManageAppleHealthVC sendAppleHealthData.")
            return}
        let qty_cat_data_count = arrySleepDict.count + arryStepsDict.count + arryHeartRateDict.count + arryExerciseTimeDict.count
            let arryQtyCatData = arrySleepDict + arryStepsDict + arryHeartRateDict + arryExerciseTimeDict

            /* Send apple works outs first */
            self.healthDataStore.sendChunksToWSAPI(userId:user_id,dateStringTimeStamp:dateStringTimeStamp ,arryAppleHealthData: arryQtyCatData) { responseResult in
                self.removeSpinner()
                switch responseResult{
                case let .success(responseDict):
                    self.strStatusMessage = self.strStatusMessage + "\n" + "2) Quantity and Category data sent successfully."
                    self.templateAlert(alertTitle: "Success", alertMessage: self.strStatusMessage)
                    self.templateAlert(alertTitle: "Processing Data", alertMessage:  responseDict["alertMessage"] ?? "<failed to get good message>")

                case .failure(_):
                    self.strStatusMessage = self.strStatusMessage + "\n" + "2) Quantity and Category data NOT sent successfully."

                    self.templateAlert(alertTitle: "Failed to Send",alertMessage: self.strStatusMessage)
                }
            }
    }
}

/* Delete and other basic methods*/
extension ManageAppleHealthVC{
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
//                if let _ = self.userStore.arryDashboardTableObjects{
                    self.userStore.arryDashboardTableObjects.removeAll { $0.sourceDataOfDepVar=="Apple Health Data" }
                self.userStore.currentDashboardObjPos = nil
                self.userStore.arryDataSourceObjects = nil
                self.userStore.boolDashObjExists = false
//                }
                
                self.removeSpinner()
                self.templateAlert(alertMessage: "Delete successful!")
            case .failure(_):
                self.removeSpinner()
                self.templateAlert(alertTitle: "Failed to delete", alertMessage: "Could be anything...")
            }
        }
    }
}
