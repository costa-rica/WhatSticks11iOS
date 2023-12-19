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
    var btnDeleteUser=UIButton()
    var swtchEmailNotifications = UISwitch()
    var lblEmailNotifications = UILabel()
    var spinnerViewManageUserVC:UIView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Account"
        print("- in ManageUserVC viewDidLoad -")
        setupEmailNotifications()
        setup_btnDeleteUser()
    }
    private func setupEmailNotifications() {
        swtchEmailNotifications.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(swtchEmailNotifications)
        swtchEmailNotifications.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: 5)).isActive = true
        swtchEmailNotifications.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive = true
        lblEmailNotifications.text = "Turn off email notifications"
        lblEmailNotifications.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblEmailNotifications)
        lblEmailNotifications.centerYAnchor.constraint(equalTo: swtchEmailNotifications.centerYAnchor).isActive = true
        lblEmailNotifications.trailingAnchor.constraint(equalTo: swtchEmailNotifications.leadingAnchor, constant: widthFromPct(percent: -2)).isActive = true
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

extension UIView {
    func printSubviews(indentation: Int = 0) {
        let indent = String(repeating: " ", count: indentation)
        print("\(indent)\(self)")

        for subview in self.subviews {
            subview.printSubviews(indentation: indentation + 2)
        }
    }
}
