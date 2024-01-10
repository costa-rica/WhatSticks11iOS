//
//  RegisterVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 07/12/2023.
//

import UIKit

class RegisterVC: TemplateVC {
    
    var userStore: UserStore!
//    var urlStore: URLStore!
    var requestStore: RequestStore!
    var locationFetcher:LocationFetcher!
    // Login/Register
    let stckVwRegister = UIStackView()//accessIdentifier set
    let stckVwEmailRow = UIStackView()//accessIdentifier set
    let stckVwPasswordRow = UIStackView()//accessIdentifier set
    let lblEmail = UILabel()
    let txtEmail = PaddedTextField()
    let lblPassword = UILabel()
    let txtPassword = PaddedTextField()
    let btnShowPassword = UIButton()
    var btnRegister=UIButton()
    
    //RegisterVC
    let lblScreenNameTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupIsDev(urlStore: requestStore.urlStore)
        // Set up tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        setup_lblTitle()
        setup_stckVwRegister()
        setup_btnRegister()
        
    }
    func setup_lblTitle(){
        lblScreenNameTitle.text = "Register"
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 45)
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        view.addSubview(lblScreenNameTitle)
        lblScreenNameTitle.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage/4)).isActive=true
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
    }
    
    func setup_stckVwRegister(){
        lblEmail.text = "Email"
        lblPassword.text = "Password"
        
        stckVwRegister.translatesAutoresizingMaskIntoConstraints = false
        stckVwEmailRow.translatesAutoresizingMaskIntoConstraints = false
        stckVwPasswordRow.translatesAutoresizingMaskIntoConstraints = false
        txtEmail.translatesAutoresizingMaskIntoConstraints = false
        txtPassword.translatesAutoresizingMaskIntoConstraints = false
        lblEmail.translatesAutoresizingMaskIntoConstraints = false
        lblPassword.translatesAutoresizingMaskIntoConstraints = false
        
        stckVwRegister.accessibilityIdentifier="stckVwRegister"
        stckVwEmailRow.accessibilityIdentifier="stckVwEmailRow"
        stckVwPasswordRow.accessibilityIdentifier = "stckVwPasswordRow"
        txtEmail.accessibilityIdentifier = "txtEmail"
        txtPassword.accessibilityIdentifier = "txtPassword"
        lblEmail.accessibilityIdentifier = "lblEmail"
        lblPassword.accessibilityIdentifier = "lblPassword"
        
        txtPassword.isSecureTextEntry = true
        btnShowPassword.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btnShowPassword.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        stckVwEmailRow.addArrangedSubview(lblEmail)
        stckVwEmailRow.addArrangedSubview(txtEmail)
        
        stckVwPasswordRow.addArrangedSubview(lblPassword)
        stckVwPasswordRow.addArrangedSubview(txtPassword)
        stckVwPasswordRow.addArrangedSubview(btnShowPassword)
        
        stckVwRegister.addArrangedSubview(stckVwEmailRow)
        stckVwRegister.addArrangedSubview(stckVwPasswordRow)
        
        stckVwRegister.axis = .vertical
        stckVwEmailRow.axis = .horizontal
        stckVwPasswordRow.axis = .horizontal
        
        stckVwRegister.spacing = 5
        stckVwEmailRow.spacing = 2
        stckVwPasswordRow.spacing = 2
        
        // Customize txtEmail
        txtEmail.layer.borderColor = UIColor.systemGray.cgColor // Adjust color as needed
        txtEmail.layer.borderWidth = 1.0 // Adjust border width as needed
        txtEmail.layer.cornerRadius = 5.0 // Adjust corner radius as needed
        txtEmail.backgroundColor = UIColor.systemBackground // Adjust for dark/light mode compatibility
        txtEmail.layer.masksToBounds = true
        
        // Customize txtPassword
        txtPassword.layer.borderColor = UIColor.systemGray.cgColor // Adjust color as needed
        txtPassword.layer.borderWidth = 1.0 // Adjust border width as needed
        txtPassword.layer.cornerRadius = 5.0 // Adjust corner radius as needed
        txtPassword.backgroundColor = UIColor.systemBackground // Adjust for dark/light mode compatibility
        txtPassword.layer.masksToBounds = true
        
        txtEmail.heightAnchor.constraint(equalToConstant: 35).isActive = true // Adjust height as needed
        txtPassword.heightAnchor.constraint(equalToConstant: 35).isActive = true // Adjust height as needed
        
        view.addSubview(stckVwRegister)
        
        NSLayoutConstraint.activate([
            stckVwRegister.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: self.bodySidePaddingPercentage)),
            stckVwRegister.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -bodySidePaddingPercentage)),
            stckVwRegister.topAnchor.constraint(equalTo: self.vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage)),
            
            lblEmail.widthAnchor.constraint(equalTo: lblPassword.widthAnchor),
        ])
        
        view.layoutIfNeeded()// <-- Realizes size of lblPassword and stckVwLogin
        
        // This code makes the widths of lblPassword and btnShowPassword take lower precedence than txtPassword.
        lblPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btnShowPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func setup_btnRegister(){
        btnRegister.setTitle("Register", for: .normal)
        btnRegister.layer.borderColor = UIColor.systemBlue.cgColor
        btnRegister.layer.borderWidth = 2
        btnRegister.backgroundColor = .systemBlue
        btnRegister.layer.cornerRadius = 10
        btnRegister.translatesAutoresizingMaskIntoConstraints = false
        btnRegister.accessibilityIdentifier="btnRegister"
        view.addSubview(btnRegister)
        
        btnRegister.topAnchor.constraint(equalTo: self.stckVwRegister.bottomAnchor, constant: heightFromPct(percent: 10)).isActive=true
        btnRegister.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        btnRegister.widthAnchor.constraint(equalToConstant: widthFromPct(percent: 80)).isActive=true
        
        btnRegister.addTarget(self, action: #selector(touchDownRegister(_:)), for: .touchDown)
        btnRegister.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc func touchDownRegister(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }
    
    @objc func touchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        //        requestLogin()
//        self.templateAlert(alertMessage: "Test")
        requestRegister()
    }
    @objc func togglePasswordVisibility() {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        let imageName = txtPassword.isSecureTextEntry ? "eye.slash" : "eye"
        btnShowPassword.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc func viewTapped() {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    
    
    func requestRegister() {
        print("- RegisterVC: requestRegister()")
//        let lat = locationFetcher.userLocation?.latitude ?? 999.99
//        let lon = locationFetcher.userLocation?.longitude ?? 999.99
//        let lat = locationFetcher.userLocation.latitude
//        let lon = locationFetcher.userLocation.longitude
        let lat = 999.99
        let lon = 999.99
        userStore.callRegisterNewUser(email: txtEmail.text!, password: txtPassword.text!,lat:lat, lon: lon) { responseResultRegister in
            DispatchQueue.main.async {
                switch responseResultRegister {
                case .success(_):
                    self.successAlert()

                case .failure(let error):
                    let errorMessage: String
                    if let userStoreError = error as? UserStoreError {
                        switch userStoreError {
                        case .failedToRecieveServerResponse:
                            errorMessage = "Failed to receive server response. Please check your network connection."
                        case .failedToRegister:
                            errorMessage = "Registration failed. Please ensure the email is not already in use."
                        case .failedDecode:
                            errorMessage = "Failed to process the server response. Please try again."
                        default:
                            errorMessage = "Failed somewhere...."
                        }
                    } else {
                        // Handle other types of errors, if necessary
                        errorMessage = "An unknown error occurred. Please try again."
                    }
                    self.templateAlert(alertMessage: errorMessage)
                }
            }
        }
    }
    
    
    func successAlert() {
        let alert = UIAlertController(title: "Success!", message: "", preferredStyle: .alert)
        // This is used to go back
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            DispatchQueue.main.async{
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                loginVC.txtEmail.text = self.txtEmail.text
                loginVC.txtPassword.text = self.txtPassword.text
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    window.rootViewController = UINavigationController(rootViewController: loginVC)
                }
//            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
