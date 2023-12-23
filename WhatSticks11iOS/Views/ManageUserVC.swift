//
//  ManageUserVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 18/12/2023.
//

import UIKit

class ManageUserVC: TemplateVC{
    
    var userStore: UserStore!
    var requestStore: RequestStore!
    var healthDataStore:HealthDataStore!
    var appleHealthDataFetcher: AppleHealthDataFetcher!
    var btnDeleteUser=UIButton()
    var swtchEmailNotifications = UISwitch()
    var lblEmailNotifications = UILabel()
//    var spinnerViewManageUserVC:UIView!
    var btnManageHealthSettings = UIButton()
    var lblFindSettingsScreenForAppleHealthPermission = UILabel()
    var lblPermissionsTitle = UILabel()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Account"
        print("- in ManageUserVC viewDidLoad -")
        
        setup_btnDeleteUser()

        setup_lblFindSettingsScreenForAppleHealthPermission()
//        setupEmailNotifications()
//        setup_btnManageHealthSettings()
    }

    
    func setup_btnDeleteUser(){
        view.addSubview(btnDeleteUser)
        btnDeleteUser.translatesAutoresizingMaskIntoConstraints=false
        btnDeleteUser.accessibilityIdentifier="btnDeleteUser"
        btnDeleteUser.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnDeleteUser.addTarget(self, action: #selector(touchUpInside_btnDeleteUser(_:)), for: .touchUpInside)
        btnDeleteUser.bottomAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: -2)).isActive=true
        btnDeleteUser.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        btnDeleteUser.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        btnDeleteUser.backgroundColor = .systemRed
        btnDeleteUser.layer.cornerRadius = 10
        btnDeleteUser.setTitle(" Delete Account ", for: .normal)
    }
    @objc func touchUpInside_btnDeleteUser(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        print("delete user api call")
        alertDeleteConfirmation()
    }
    func setup_lblFindSettingsScreenForAppleHealthPermission(){
        
        view.addSubview(lblPermissionsTitle)
        lblPermissionsTitle.text = "Apple Health Permissions:"
        lblPermissionsTitle.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblPermissionsTitle.translatesAutoresizingMaskIntoConstraints = false
        lblPermissionsTitle.accessibilityIdentifier="lblPermissionsTitle"
        lblPermissionsTitle.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: 3)).isActive=true
        lblPermissionsTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        lblPermissionsTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        
        
        view.addSubview(lblFindSettingsScreenForAppleHealthPermission)
        lblFindSettingsScreenForAppleHealthPermission.translatesAutoresizingMaskIntoConstraints=false
        lblFindSettingsScreenForAppleHealthPermission.accessibilityIdentifier="lblFindSettingsScreenForAppleHealthPermission"
        let text_for_message = "Go to Settings > Health > Data Access & Devices > WhatSticks11iOS to grant access.\n\nFor this app to work properly please make sure all data types are allowed."
        lblFindSettingsScreenForAppleHealthPermission.text = text_for_message
        lblFindSettingsScreenForAppleHealthPermission.numberOfLines = 0
        lblFindSettingsScreenForAppleHealthPermission.topAnchor.constraint(equalTo: lblPermissionsTitle.bottomAnchor, constant: heightFromPct(percent: 3)).isActive=true
        lblFindSettingsScreenForAppleHealthPermission.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        lblFindSettingsScreenForAppleHealthPermission.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
    }
    private func setupEmailNotifications() {
        swtchEmailNotifications.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(swtchEmailNotifications)
        swtchEmailNotifications.topAnchor.constraint(equalTo: lblFindSettingsScreenForAppleHealthPermission.bottomAnchor, constant: heightFromPct(percent: 5)).isActive = true
        swtchEmailNotifications.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive = true
        lblEmailNotifications.text = "Turn off email notifications"
        lblEmailNotifications.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblEmailNotifications)
        lblEmailNotifications.centerYAnchor.constraint(equalTo: swtchEmailNotifications.centerYAnchor).isActive = true
        lblEmailNotifications.trailingAnchor.constraint(equalTo: swtchEmailNotifications.leadingAnchor, constant: widthFromPct(percent: -2)).isActive = true
    }
    func setup_btnManageHealthSettings(){
        view.addSubview(btnManageHealthSettings)
        btnManageHealthSettings.translatesAutoresizingMaskIntoConstraints=false
        btnManageHealthSettings.accessibilityIdentifier="btnManageHealthSettings"
        btnManageHealthSettings.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnManageHealthSettings.addTarget(self, action: #selector(touchUpInside_btnManageHealthSettings(_:)), for: .touchUpInside)
        btnManageHealthSettings.bottomAnchor.constraint(equalTo: btnDeleteUser.topAnchor, constant: heightFromPct(percent: -10)).isActive=true
        btnManageHealthSettings.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        btnManageHealthSettings.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        btnManageHealthSettings.backgroundColor = .systemBlue
        btnManageHealthSettings.layer.cornerRadius = 10
        btnManageHealthSettings.setTitle(" Go to Apple Health Data Settings ", for: .normal)
    }
    @objc func touchUpInside_btnManageHealthSettings(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        print(" btnManageHealthSettings ")
        self.appleHealthDataFetcher.authorizeHealthKit()
//        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//            return
//        }
//        // ARticle that might be helpful: https://medium.com/p/20871139d72f
////        guard let settingsHealthUrl = URL(string: "x-apple-health://") else {
////            return
////        }
//        guard let settingsHealthUrl = URL(string: "prefs:root=HEALTH") else {
//            print("open | prefs:root=HEALTH -- > didn't work")
//            return
//        }


//        if UIApplication.shared.canOpenURL(settingsHealthUrl) {
//            UIApplication.shared.open(settingsHealthUrl, options: [:], completionHandler: nil)
//        }
//        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//            if UIApplication.shared.canOpenURL(settingsURL) {
//                UIApplication.shared.open(settingsURL)
//            }
//        }
    }
    
    @objc func alertDeleteConfirmation() {
        let alertController = UIAlertController(title: "Are you sure you want to delete?", message: "This will only delete data from What Sticks Databases. Your source data will be unaffected.", preferredStyle: .alert)
        // 'Yes' action
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // Handle the 'Yes' action here
            self?.showSpinner()
            self?.deleteUser()
        }
        // 'No' action
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        // Adding actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        // Presenting the alert
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteUser(){
        self.userStore.callDeleteUser { responseResult in
            switch responseResult{
            case .success(_):
                print("- ManageUserVC: received success response from WSAPI")
                self.userStore.deleteJsonFile(filename: "user.json")
                self.userStore.deleteJsonFile(filename: "arryDashboardTableObjects.json")
                self.userStore.deleteJsonFile(filename: "arryDataSourceObjects.json")
                self.userStore.arryDataSourceObjects = [DataSourceObject]()
                self.userStore.arryDashboardTableObjects = [DashboardTableObject]()
                self.removeSpinner()
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                loginVC.txtEmail.text = ""
                loginVC.txtPassword.text = ""
                
                // Accessing the scene delegate and then the window
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    window.rootViewController = UINavigationController(rootViewController: loginVC)
                }
                

            case let .failure(error):
                print("- got an error response for delete_user endpoint")
                self.removeSpinner()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.templateAlert(alertMessage: error.localizedDescription)
                }
            }
        }
    }


}



class InfoVC: UIViewController{
//    var strgTitle
//    var strgDefinition: String
    var dashboardTableObject: DashboardTableObject?
    var lblTitle = UILabel()
    var lblDetails = UILabel()
    var vwInfo = UIView()
    
    init(dashboardTableObject: DashboardTableObject?){
//        self.strgDefinition = strgDefinition
        self.dashboardTableObject = dashboardTableObject
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's frame to take up most of the screen except for 5 percent all sides
        self.view.frame = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        setupView()
        addTapGestureRecognizer()
    }
    private func setupView(){
        lblTitle.text = self.dashboardTableObject?.dependentVarName
        lblTitle.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblTitle.translatesAutoresizingMaskIntoConstraints=false
        lblDetails.text = self.dashboardTableObject?.definition
        lblDetails.numberOfLines = 0
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        vwInfo.backgroundColor = UIColor.black
        vwInfo.layer.cornerRadius = 12
        vwInfo.layer.borderColor = UIColor(named: "gray-500")?.cgColor
        vwInfo.layer.borderWidth = 2
        vwInfo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vwInfo)
        vwInfo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive=true
        vwInfo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        vwInfo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive=true
        vwInfo.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 20)).isActive=true
        
        
        vwInfo.addSubview(lblTitle)
        lblTitle.topAnchor.constraint(equalTo: vwInfo.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        lblTitle.leadingAnchor.constraint(equalTo: vwInfo.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        vwInfo.addSubview(lblDetails)
        lblDetails.translatesAutoresizingMaskIntoConstraints=false
        lblDetails.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: heightFromPct(percent: 2)).isActive=true
        lblDetails.leadingAnchor.constraint(equalTo: vwInfo.leadingAnchor,constant: widthFromPct(percent: 2)).isActive=true
        lblDetails.trailingAnchor.constraint(equalTo: vwInfo.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
//        lblDetails.centerYAnchor.constraint(equalTo: vwInfo.centerYAnchor).isActive=true
    }
    
    private func addTapGestureRecognizer() {
        // Create a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        // Add the gesture recognizer to the view
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
            dismiss(animated: true, completion: nil)
    }

}
