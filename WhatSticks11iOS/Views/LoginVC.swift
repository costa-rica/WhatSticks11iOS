//
//  ViewController.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 06/12/2023.
//

import UIKit
//import HealthKit

class LoginVC: TemplateVC {
    
    var userStore: UserStore!
    var urlStore: URLStore!
    var requestStore: RequestStore!
    var appleHealthDataFetcher: AppleHealthDataFetcher!
//    var hkHealthStore: HKHealthStore!
    var healthDataStore: HealthDataStore!
    
    // Login
    let stckVwLogin = UIStackView()//accessIdentifier set
    let stckVwEmailRow = UIStackView()//accessIdentifier set
    let stckVwPasswordRow = UIStackView()//accessIdentifier set
    let lblEmail = UILabel()
    var txtEmail = PaddedTextField()
    let lblPassword = UILabel()
    var txtPassword = PaddedTextField()
    let btnShowPassword = UIButton()
    var btnLogin=UIButton()
    
    // Remember me
    var stckVwRememberMe: UIStackView!//accessIdentifier set
    let swRememberMe = UISwitch()
    
    // Forgot Password
    var signUpLabel:UILabel!
    var btnForgotPassword:UIButton!
    
    //LoginVC
    let lblScreenNameTitle = UILabel()
    
    var lblLogout:UILabel!
    
    var token = "token" {
        didSet{
            if token != "token"{
                if swRememberMe.isOn{
//                    self.userStore.writeUserJson()
                    self.userStore.writeObjectToJsonFile(object: self.userStore.user, filename: "user.json")
                } else {
//                    self.userStore.deleteUserJsonFile()
                    self.userStore.deleteJsonFile(filename: "user.json")
                    self.txtEmail.text = ""
                    self.txtPassword.text = ""
                }
                self.userStore.callSendDataSourceObjects { responseResult in
                    switch responseResult{
                    case let .success(arryDataSourceObjects):
                        self.userStore.arryDataSourceObjects = arryDataSourceObjects
//                        self.userStore.writeDataSourceJson()
                        self.userStore.writeObjectToJsonFile(object: arryDataSourceObjects, filename: "arryDataSourceObjects.json")
//                        let dash_default = DashboardTableObject()

                        self.performSegue(withIdentifier: "goToDashboardVC", sender: self)
                    case let .failure(error):
                        self.templateAlert(alertTitle: "Alert", alertMessage: "Login successful, but failed to get user dashboard data. Contact Nick at: nrodrig1@gmail.com. Error: \(error)")
                    }
                }
            }
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestStore = RequestStore()
        self.userStore = UserStore()
        self.userStore.requestStore = self.requestStore
        self.appleHealthDataFetcher = AppleHealthDataFetcher()
        self.healthDataStore = HealthDataStore()
        self.healthDataStore.requestStore = self.requestStore
        
        // Set up tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
//        self.hkHealthStore = HKHealthStore()

        setup_lblTitle()
        setup_stckVwLogin()
        setup_btnLogin()
        setup_stckVwRememberMe()
        setupForgotPasswordButton()
        setupSignUpLabel()
        setup_checkFiles()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.isInitialViewController=true
        self.changeLogoForLoginVC()
    }// This is just to set up logo in vwTopBar
    func setup_checkFiles(){
        userStore.checkUserJson { responseResult in
            DispatchQueue.main.async {
                switch responseResult{
                case let .success(user_obj):
                    self.txtEmail.text=user_obj.email
                    self.txtPassword.text=user_obj.password
                case .failure(_):
                    print("no user found")
                }
            }
        }
        userStore.checkDashboardJson { result in
            DispatchQueue.main.async{
                switch result{
                case .success(_):
                    print("arryDashboardTableObjects.json file found")
                case let .failure(error):
                    print("No arryDashboardTableObjects.json file found, error: \(error)")
                }
            }
        }
        userStore.checkDataSourceJson { result in
            DispatchQueue.main.async{
                switch result{
                case .success(_):
                    print("arryDataSourceObjects.json file found")
                case let .failure(error):
                    print("No arryDataSourceObjects.json file found, error: \(error)")
                }
            }
        }
    }
    func setup_lblTitle(){
        lblScreenNameTitle.text = "Login"
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 45)
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        view.addSubview(lblScreenNameTitle)
        lblScreenNameTitle.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage/4)).isActive=true
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
    }
    
    func setup_stckVwLogin(){
        lblEmail.text = "Email"
        lblPassword.text = "Password"
        
        stckVwLogin.translatesAutoresizingMaskIntoConstraints = false
        stckVwEmailRow.translatesAutoresizingMaskIntoConstraints = false
        stckVwPasswordRow.translatesAutoresizingMaskIntoConstraints = false
        txtEmail.translatesAutoresizingMaskIntoConstraints = false
        txtPassword.translatesAutoresizingMaskIntoConstraints = false
        lblEmail.translatesAutoresizingMaskIntoConstraints = false
        lblPassword.translatesAutoresizingMaskIntoConstraints = false
        
        stckVwLogin.accessibilityIdentifier="stckVwLogin"
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
        
        stckVwLogin.addArrangedSubview(stckVwEmailRow)
        stckVwLogin.addArrangedSubview(stckVwPasswordRow)
        
        stckVwLogin.axis = .vertical
        stckVwEmailRow.axis = .horizontal
        stckVwPasswordRow.axis = .horizontal
        
        stckVwLogin.spacing = 5
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
        
        view.addSubview(stckVwLogin)
        
        NSLayoutConstraint.activate([
            stckVwLogin.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: self.bodySidePaddingPercentage)),
            stckVwLogin.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -bodySidePaddingPercentage)),
            stckVwLogin.topAnchor.constraint(equalTo: self.vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage)),
            
            lblEmail.widthAnchor.constraint(equalTo: lblPassword.widthAnchor),
        ])
        
        view.layoutIfNeeded()// <-- Realizes size of lblPassword and stckVwLogin
        
        // This code makes the widths of lblPassword and btnShowPassword take lower precedence than txtPassword.
        lblPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btnShowPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func setup_btnLogin(){
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.layer.borderColor = UIColor.systemBlue.cgColor
        btnLogin.layer.borderWidth = 2
        btnLogin.backgroundColor = .systemBlue
        btnLogin.layer.cornerRadius = 10
        btnLogin.translatesAutoresizingMaskIntoConstraints = false
        btnLogin.accessibilityIdentifier="btnLogin"
        view.addSubview(btnLogin)
        
        btnLogin.topAnchor.constraint(equalTo: self.stckVwLogin.bottomAnchor, constant: heightFromPct(percent: 10)).isActive=true
        btnLogin.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        btnLogin.widthAnchor.constraint(equalToConstant: widthFromPct(percent: 80)).isActive=true
        
        btnLogin.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnLogin.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
    }
    
    
    @objc func touchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        requestLogin()
    }
    
    func requestLogin(){
        userStore.callLoginUser(email: txtEmail.text ?? "", password: txtPassword.text ?? "") { responseResultLogin in
            DispatchQueue.main.async {
            switch responseResultLogin{
            case let .success(user_obj):
                print("")
                self.requestStore.token = user_obj.token
                self.userStore.user.id = user_obj.id
                self.userStore.user.token = user_obj.token
                self.userStore.user.email = self.txtEmail.text
                self.userStore.user.password = self.txtPassword.text
                self.userStore.user.username = user_obj.username
                self.token = user_obj.token!
                if let unwrap_oura_token = user_obj.oura_token{
                    self.userStore.user.oura_token = unwrap_oura_token
                }
                self.requestStore.token = user_obj.token!
            case let .failure(error):
                
                
                self.templateAlert(alertTitle: "\(error)", alertMessage: "Did you register? \n ¯\\_(ツ)_/¯ ")
                }
            }
        }
    }
    
    @objc func togglePasswordVisibility() {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        let imageName = txtPassword.isSecureTextEntry ? "eye.slash" : "eye"
        btnShowPassword.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func setup_stckVwRememberMe() {
        stckVwRememberMe = UIStackView()
        let lblRememberMe = UILabel()
        
        lblRememberMe.text = "Remember Me"
        stckVwRememberMe.spacing = 10
        stckVwRememberMe.addArrangedSubview(lblRememberMe)
        stckVwRememberMe.addArrangedSubview(swRememberMe)
        view.addSubview(stckVwRememberMe)
        
        stckVwRememberMe.translatesAutoresizingMaskIntoConstraints = false
        lblRememberMe.translatesAutoresizingMaskIntoConstraints = false
        swRememberMe.translatesAutoresizingMaskIntoConstraints = false
        stckVwRememberMe.accessibilityIdentifier = "stckVwRememberMe"
        lblRememberMe.accessibilityIdentifier = "lblRememberMe"
        swRememberMe.accessibilityIdentifier = "swRememberMe"
        
        stckVwRememberMe.topAnchor.constraint(equalTo: stckVwLogin.bottomAnchor, constant: heightFromPct(percent: 2)).isActive=true
        stckVwRememberMe.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
        stckVwRememberMe.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -bodySidePaddingPercentage)).isActive=true
        
        swRememberMe.isOn = true
    }
    private func setupForgotPasswordButton() {
        btnForgotPassword = UIButton(type: .system)
        btnForgotPassword.setTitle("Forgot Password?", for: .normal)
        btnForgotPassword.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)

        // Layout the button as needed
        btnForgotPassword.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnForgotPassword)
        btnForgotPassword.topAnchor.constraint(equalTo: btnLogin.bottomAnchor, constant: heightFromPct(percent: 5)).isActive=true
        btnForgotPassword.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
    }
    
    @objc private func forgotPasswordTapped() {
        performSegue(withIdentifier: "goToForgotPasswordVC", sender: self)
    }
    private func setupSignUpLabel() {
        let fullText = "Don’t have an account? Sign up"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "Sign up")
        
        // Add underlining or color to 'Sign up'
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: range)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        signUpLabel = UILabel()
        view.addSubview(signUpLabel)
        signUpLabel.translatesAutoresizingMaskIntoConstraints=false
        signUpLabel.accessibilityIdentifier="signUpLabel"
        signUpLabel.attributedText = attributedString
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signUpTapped)))
        
        signUpLabel.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 1)).isActive=true
        signUpLabel.centerXAnchor.constraint(equalTo: vwFooter.centerXAnchor).isActive=true
    }
    @objc func viewTapped() {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    @objc func signUpTapped() {
        performSegue(withIdentifier: "goToRegisterVC", sender: self)
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToRegisterVC"){
            let registerVC = segue.destination as! RegisterVC
            registerVC.userStore = self.userStore
            registerVC.requestStore = self.requestStore
        }
        else if (segue.identifier == "goToDashboardVC"){
            let dashboardVC = segue.destination as! DashboardVC
            dashboardVC.userStore = self.userStore
            dashboardVC.requestStore = self.requestStore
            dashboardVC.appleHealthDataFetcher = self.appleHealthDataFetcher
            dashboardVC.healthDataStore = self.healthDataStore
            
//            if let unwp_arryDashTableObj = self.userStore.arryDashboardTableObjects{
//                dashboardVC.dashboardTableObject = unwp_arryDashTableObj[0]
//            }
            self.token = "token"// reset login
        }
    }
    
}

