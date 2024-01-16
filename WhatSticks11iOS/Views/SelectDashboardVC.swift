//
//  SelectDasboardVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 04/01/2024.
//

import UIKit

class SelectDashboardVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var delegate: SelectDashboardVCDelegate?
//    var arryDashboardTableObject: [DashboardTableObject]?
    var userStore: UserStore?
    var lblTitle = UILabel()
    var pickerDashboard = UIPickerView()
    var btnSubmit = UIButton()
    var vwSelectDashboard = UIView()

    init(userStore:UserStore?){
        self.userStore=userStore
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
        // Set the picker to the current dashboard position
        if let dashboardPos = userStore?.currentDashboardObjPos, dashboardPos < (userStore?.arryDashboardTableObjects.count ?? 0) {
            pickerDashboard.selectRow(dashboardPos, inComponent: 0, animated: false)
        }
    }

    private func setupView(){
        
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        vwSelectDashboard.backgroundColor = UIColor.systemBackground
        vwSelectDashboard.layer.cornerRadius = 12
        vwSelectDashboard.layer.borderColor = UIColor(named: "gray-500")?.cgColor
        vwSelectDashboard.layer.borderWidth = 2
        vwSelectDashboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vwSelectDashboard)
        vwSelectDashboard.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive=true
        vwSelectDashboard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        vwSelectDashboard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive=true
        vwSelectDashboard.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 20)).isActive=true
        
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
        pickerDashboard.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: heightFromPct(percent: -0.5)).isActive = true
        pickerDashboard.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 12)).isActive=true
        pickerDashboard.leadingAnchor.constraint(equalTo: vwSelectDashboard.leadingAnchor, constant: widthFromPct(percent: 0.5)).isActive=true
        pickerDashboard.trailingAnchor.constraint(equalTo: vwSelectDashboard.trailingAnchor, constant: widthFromPct(percent: -0.5)).isActive=true
        pickerDashboard.dataSource = self
        pickerDashboard.delegate = self

    }

    // UIPickerViewDataSource and UIPickerViewDelegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
//        return arryDashboardTableObject?.count ?? 0
        return userStore?.arryDataSourceObjects?.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (userStore?.arryDashboardTableObjects[row]) != nil {
//        if let selectedDashboard = arryDashboardTableObject?[row] {
            delegate?.didSelectDashboard(currentDashboardObjPos: row)
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return arryDashboardTableObject?[row].dependentVarName
        return userStore?.arryDashboardTableObjects[row].dependentVarName
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




