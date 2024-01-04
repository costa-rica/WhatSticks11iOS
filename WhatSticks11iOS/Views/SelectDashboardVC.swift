//
//  SelectDasboardVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 04/01/2024.
//

import UIKit

class SelectDashboardVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var delegate: SelectDashboardVCDelegate?
    var arryDashboardTableObject: [DashboardTableObject]?
    var lblTitle = UILabel()
    var pickerDashboard = UIPickerView()
    var btnSubmit = UIButton()
    var vwSelectDashboard = UIView()

    init(arryDashboardTableObject: [DashboardTableObject]?){
        self.arryDashboardTableObject = arryDashboardTableObject
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        setupView()
        addTapGestureRecognizer()
    }

    private func setupView(){
        
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        vwSelectDashboard.backgroundColor = UIColor.black
        vwSelectDashboard.layer.cornerRadius = 12
        vwSelectDashboard.layer.borderColor = UIColor(named: "gray-500")?.cgColor
        vwSelectDashboard.layer.borderWidth = 2
        vwSelectDashboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vwSelectDashboard)
        vwSelectDashboard.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive=true
        vwSelectDashboard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        vwSelectDashboard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive=true
        vwSelectDashboard.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 40)).isActive=true
        
        
        // lblTitle setup
        lblTitle.text = " Select Your Dashboard "
        lblTitle.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        vwSelectDashboard.addSubview(lblTitle)
        lblTitle.centerXAnchor.constraint(equalTo: vwSelectDashboard.centerXAnchor).isActive = true
        lblTitle.topAnchor.constraint(equalTo: vwSelectDashboard.topAnchor, constant: heightFromPct(percent: 5)).isActive = true

        // pickerDashboard setup
        pickerDashboard.translatesAutoresizingMaskIntoConstraints = false
        vwSelectDashboard.addSubview(pickerDashboard)
        pickerDashboard.centerXAnchor.constraint(equalTo: vwSelectDashboard.centerXAnchor).isActive = true
        pickerDashboard.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: heightFromPct(percent: 5)).isActive = true
        pickerDashboard.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 10)).isActive=true
        pickerDashboard.dataSource = self
        pickerDashboard.delegate = self

        // btnSubmit setup
        btnSubmit.setTitle(" Select ", for: .normal)
        btnSubmit.backgroundColor = .systemBlue
        btnSubmit.translatesAutoresizingMaskIntoConstraints = false
        btnSubmit.layer.cornerRadius = 10
        vwSelectDashboard.addSubview(btnSubmit)
        btnSubmit.trailingAnchor.constraint(equalTo: vwSelectDashboard.trailingAnchor,constant: widthFromPct(percent: -2)).isActive = true
        btnSubmit.topAnchor.constraint(equalTo: pickerDashboard.bottomAnchor, constant: heightFromPct(percent: 5)).isActive = true
        btnSubmit.addTarget(self, action: #selector(touchUpInside_btnSubmit(_:)), for: .touchUpInside)
    }

    // UIPickerViewDataSource and UIPickerViewDelegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arryDashboardTableObject?.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arryDashboardTableObject?[row].dependentVarName
    }

    @objc func touchUpInside_btnSubmit(_ sender: UIButton) {
        let selectedRow = pickerDashboard.selectedRow(inComponent: 0)
        if let selectedDashboard = arryDashboardTableObject?[selectedRow] {
//            print("Selected: \(selectedDashboard.dependentVarName), Position: \(selectedRow)")
            delegate?.didSelectDashboard(currentDashboardObjPos: selectedRow)
        }
        self.dismiss(animated: true, completion: nil)
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



//
//class SelectDashboardVC: UIViewController{
//
//    var arryDashboardTableObject: [DashboardTableObject]?
//    var lblTitle = UILabel()
//    var btnSubmit = UIButton()
//    
//    init(arryDashboardTableObject: [DashboardTableObject]?){
//        self.arryDashboardTableObject = arryDashboardTableObject
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Set the view's frame to take up most of the screen except for 5 percent all sides
//        self.view.frame = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
//        setupView()
//        addTapGestureRecognizer()
//    }
//    private func setupView(){
//        lblTitle.text = " Select Your Dashboard "
//        lblTitle.font = UIFont(name: "ArialRoundedMTBold", size: 20)
//        lblTitle.translatesAutoresizingMaskIntoConstraints=false
//        lblTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: heightFromPct(percent: 1)).isActive=true
//        lblTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: 1)).isActive=true
//
//        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
//
//        view.addSubview(btnSubmit)
//        btnSubmit.translatesAutoresizingMaskIntoConstraints=false
//        btnSubmit.accessibilityIdentifier="btnSubmit"
//        btnSubmit.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
//        btnSubmit.addTarget(self, action: #selector(touchUpInside_btnSubmit(_:)), for: .touchUpInside)
//        btnSubmit.topAnchor.constraint(equalTo: view.topAnchor, constant: heightFromPct(percent: 1)).isActive=true
//        btnSubmit.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: 1)).isActive=true
//        
//    }
//    @objc func touchDown(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
//            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        }, completion: nil)
//    }
//    @objc func touchUpInside_btnSubmit(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
//            sender.transform = .identity
//        }, completion: nil)
//        print()
//    }
//    
//    private func addTapGestureRecognizer() {
//        // Create a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        // Add the gesture recognizer to the view
//        view.addGestureRecognizer(tapGesture)
//    }
//    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
//            dismiss(animated: true, completion: nil)
//    }
//
//}

