//
//  TemplateVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 07/12/2023.
//

import UIKit

class TemplateVC: UIViewController {
    
    let vwTopSafeBar = UIView()
    let vwTopBar = UIView()
    let lblScreenName = UILabel()
    let lblUsername = UILabel()
    let imgVwLogo = UIImageView()
    let vwFooter = UIView()
    var bodySidePaddingPercentage = Float(5.0)
    var bodyTopPaddingPercentage = Float(20.0)
    var spinnerView: UIView?
    var messageLabel = UILabel()
    var imgLogoTrailingAnchor: NSLayoutConstraint!
    var lblScreenNameTopAnchor: NSLayoutConstraint!
    var lblUserNameBottomAnchor: NSLayoutConstraint!
    
    var isInitialViewController: Bool = false
     
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    func setupIsDev(urlStore:URLStore){
        if urlStore.apiBase == .dev{
            vwTopSafeBar.backgroundColor = UIColor(named: "yellow-dev")
        }
    }
    private func setupViews() {
        // Setup vwTopSafeBar
        vwTopSafeBar.backgroundColor = UIColor(named: "gray02")
        view.addSubview(vwTopSafeBar)
        vwTopSafeBar.translatesAutoresizingMaskIntoConstraints = false
        vwTopSafeBar.accessibilityIdentifier = "vwTopSafeBar"
        vwTopSafeBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vwTopSafeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vwTopSafeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        vwTopSafeBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true
        // Setup vwTopBar
        vwTopBar.backgroundColor = UIColor(named: "gray02")
        view.addSubview(vwTopBar)
        vwTopBar.translatesAutoresizingMaskIntoConstraints = false
        vwTopBar.accessibilityIdentifier = "vwTopBar"
        vwTopBar.topAnchor.constraint(equalTo: vwTopSafeBar.bottomAnchor).isActive = true
        vwTopBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vwTopBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        vwTopBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.10).isActive = true
//        if let unwrapped_image = UIImage(named: "wsLogo192") {
        if let unwrapped_image = UIImage(named: "wsLogoNoNameMedium") {
            imgVwLogo.image = unwrapped_image.scaleImage(toSize: CGSize(width: 15, height: 15))
        }
        // Setup labels and image view
        lblScreenName.translatesAutoresizingMaskIntoConstraints=false
        lblUsername.translatesAutoresizingMaskIntoConstraints=false
        vwTopBar.addSubview(lblScreenName)
        vwTopBar.addSubview(lblUsername)
        lblScreenNameTopAnchor = lblScreenName.topAnchor.constraint(equalTo: vwTopBar.topAnchor,constant: heightFromPct(percent: 1))
        lblScreenNameTopAnchor.isActive=true
        lblScreenName.centerXAnchor.constraint(equalTo: vwTopBar.centerXAnchor, constant: widthFromPct(percent: 1)).isActive=true
        
        lblUserNameBottomAnchor = lblUsername.bottomAnchor.constraint(equalTo: vwTopBar.bottomAnchor,constant:heightFromPct(percent: -1))
        lblUserNameBottomAnchor.isActive=true
        lblUsername.centerXAnchor.constraint(equalTo: vwTopBar.centerXAnchor).isActive=true
        
        setScreenNameFontSize()
//        lblUsername.font = UIFont(name: "ArialRoundedMTBold", size: 18)
        //setup imgVwLogo
        imgVwLogo.translatesAutoresizingMaskIntoConstraints = false
        vwTopBar.addSubview(imgVwLogo)
        imgVwLogo.accessibilityIdentifier = "imgVwLogo"
        imgVwLogo.heightAnchor.constraint(equalTo: imgVwLogo.widthAnchor, multiplier: 1.0).isActive = true
        imgVwLogo.centerYAnchor.constraint(equalTo: vwTopBar.centerYAnchor).isActive=true
        imgLogoTrailingAnchor = imgVwLogo.trailingAnchor.constraint(equalTo: vwTopBar.trailingAnchor,constant: widthFromPct(percent: -1))
        imgLogoTrailingAnchor.isActive=true
        // Setup vwFooter
        vwFooter.backgroundColor = UIColor(named: "gray02")
        view.addSubview(vwFooter)
        vwFooter.translatesAutoresizingMaskIntoConstraints = false
        vwFooter.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vwFooter.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vwFooter.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        vwFooter.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    }
    
    func changeLogoForLoginVC(){
        let logoImageName = isInitialViewController ? "wsLogo192" : "wsLogoSmallNoName"
        if let unwrapped_image = UIImage(named: logoImageName) {
            imgVwLogo.image = unwrapped_image.scaleImage(toSize: CGSize(width: 23, height: 23))
        }
        imgLogoTrailingAnchor.isActive=false
        imgVwLogo.trailingAnchor.constraint(equalTo: vwTopBar.trailingAnchor,constant: widthFromPct(percent: -bodySidePaddingPercentage)).isActive=true
    }
    
    func setScreenNameFontSize() {
        lblScreenName.font = UIFont(name: "ArialRoundedMTBold", size: 30)
        lblUsername.font = UIFont(name: "ArialRoundedMTBold", size: 18)
        lblUsername.textColor = .gray
        if let unwp_lblScreenNameText = lblScreenName.text{
            if unwp_lblScreenNameText.count > 12 {
                lblScreenName.numberOfLines = 0
                lblScreenName.widthAnchor.constraint(equalToConstant: widthFromPct(percent: 60)).isActive=true
                lblScreenName.textAlignment = .center
                let lblScreenNameFontSize = -1 * unwp_lblScreenNameText.count + 40// Continuous function to size lblScreenName
                lblScreenName.font = UIFont(name: "ArialRoundedMTBold", size: CGFloat(Int(lblScreenNameFontSize)))
                lblScreenNameTopAnchor.isActive=false
                lblUserNameBottomAnchor.isActive=false
                lblScreenName.topAnchor.constraint(equalTo: vwTopBar.topAnchor).isActive=true
                lblUsername.bottomAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: -0.25)).isActive=true
            }
        }
    }
    @objc func touchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }
    func templateAlert(alertTitle:String = "Alert",alertMessage: String,  backScreen: Bool = false) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        // This is used to go back
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if backScreen {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func showSpinner() {
        spinnerView = UIView(frame: self.view.bounds)
        
        spinnerView?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)// makes spinner bigger
        activityIndicator.center = spinnerView!.center
        activityIndicator.startAnimating()
        spinnerView?.addSubview(activityIndicator)
        messageLabel.text = "This is a lot of data so it may take more than a minute"
        messageLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.frame = CGRect(x: 0, y: activityIndicator.frame.maxY + 20, width: spinnerView!.bounds.width, height: 50)
        messageLabel.isHidden = true
        spinnerView?.addSubview(messageLabel)
        self.view.addSubview(spinnerView!)
        spinnerView?.accessibilityIdentifier = "spinnerView"
        activityIndicator.accessibilityIdentifier = "activityIndicator"
        // Timer to show the label after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            self.messageLabel.isHidden = false
        }
    }
    func removeSpinner() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
        print("removeSpinner() completed")
    }
}

