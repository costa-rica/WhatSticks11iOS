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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
        
        if let unwrapped_image = UIImage(named: "wsLogo192") {
            imgVwLogo.image = unwrapped_image.scaleImage(toSize: CGSize(width: 25, height: 25))
        }

        // Setup labels and image view
        lblScreenName.translatesAutoresizingMaskIntoConstraints=false
        lblUsername.translatesAutoresizingMaskIntoConstraints=false
        vwTopBar.addSubview(lblScreenName)
        vwTopBar.addSubview(lblUsername)
        
        lblScreenName.topAnchor.constraint(equalTo: vwTopBar.topAnchor,constant: heightFromPct(percent: 1)).isActive=true
        lblScreenName.centerXAnchor.constraint(equalTo: vwTopBar.centerXAnchor).isActive=true
        lblUsername.bottomAnchor.constraint(equalTo: vwTopBar.bottomAnchor,constant:heightFromPct(percent: -1)).isActive=true
        lblUsername.centerXAnchor.constraint(equalTo: vwTopBar.centerXAnchor).isActive=true
//        lblScreenName.font = UIFont(name: "ArialRoundedMTBold", size: 33)
        setScreenNameFontSize()
        lblUsername.font = UIFont(name: "ArialRoundedMTBold", size: 18)
        
        //setup imgVwLogo
        imgVwLogo.translatesAutoresizingMaskIntoConstraints = false
        vwTopBar.addSubview(imgVwLogo)
        imgVwLogo.accessibilityIdentifier = "imgVwLogo"
        imgVwLogo.heightAnchor.constraint(equalTo: imgVwLogo.widthAnchor, multiplier: 1.0).isActive = true
        imgVwLogo.topAnchor.constraint(equalTo: vwTopSafeBar.bottomAnchor).isActive=true
        imgVwLogo.trailingAnchor.constraint(equalTo: vwTopBar.trailingAnchor,constant: widthFromPct(percent: -bodySidePaddingPercentage)).isActive=true


        // Setup vwFooter
        vwFooter.backgroundColor = UIColor(named: "gray02")
        view.addSubview(vwFooter)
        vwFooter.translatesAutoresizingMaskIntoConstraints = false
        vwFooter.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vwFooter.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vwFooter.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        vwFooter.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    }
    func setScreenNameFontSize(size: CGFloat? = nil) {
        let fontSize = size ?? 33 // Default to 33 if no size is provided
        lblScreenName.font = UIFont(name: "ArialRoundedMTBold", size: fontSize)
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

        // Timer to show the label after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            self.messageLabel.isHidden = false
        }
    }
    func removeSpinner() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
    
}

