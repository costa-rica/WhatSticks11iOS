//
//  ManageDataVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 08/12/2023.
//

import UIKit

class ManageDataVC: TemplateVC, ManageDataVCDelegate{
    
    var userStore: UserStore!
    var requestStore: RequestStore!
    var appleHealthDataFetcher:AppleHealthDataFetcher!
    var healthDataStore: HealthDataStore!
    var btnGoToManageDataVC=UIButton()
    var btnGoToLoginVC=UIButton()
    
    var tblDataSources=UITableView()
    
//    var spinnerView: UIView?
//    var alertMessageCustom:String?
    var segueSource:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Manage Data"
        self.setScreenNameFontSize(size: 30)
        tblDataSources.delegate = self
        tblDataSources.dataSource = self
        tblDataSources.register(ManageDataTableCell.self, forCellReuseIdentifier: "ManageDataTableCell")
        tblDataSources.rowHeight = UITableView.automaticDimension
        tblDataSources.estimatedRowHeight = 100
        setup_tbl()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tblDataSources.refreshControl = refreshControl
    }
    override func viewDidAppear(_ animated: Bool) {
        for obj in userStore.arryDataSourceObjects!{
            print("\(obj.name!): \(obj.recordCount!)")
        }
        DispatchQueue.main.async{
//            self.tblDataSources.reloadData()
            // Assuming you want to reload all rows
            let section = 0 // Modify this if you have multiple sections
            let numberOfRows = self.tblDataSources.numberOfRows(inSection: section)
            let indexPaths = (0..<numberOfRows).map { IndexPath(row: $0, section: section) }

            self.tblDataSources.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    func setup_tbl(){
        tblDataSources.accessibilityIdentifier = "tblDataSources"
        tblDataSources.translatesAutoresizingMaskIntoConstraints=false
        view.addSubview(tblDataSources)
        tblDataSources.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: 5)).isActive=true
        tblDataSources.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        tblDataSources.bottomAnchor.constraint(equalTo: vwFooter.topAnchor).isActive=true
        tblDataSources.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true        
    }
    @objc private func refreshData(_ sender: UIRefreshControl) {

        self.userStore.callSendDataSourceObjects { responseResult in
            switch responseResult{
            case let .success(jsonDataSourceObj):
                self.userStore.arryDataSourceObjects = jsonDataSourceObj
                self.userStore.writeDataSourceJson()
                self.refreshValuesInTable()
            case let .failure(error):
                sender.endRefreshing()
                self.templateAlert(alertTitle: "Alert", alertMessage: "Failed to update data. Error: \(error)")
            }
        }
    }
    func refreshValuesInTable(){
        DispatchQueue.main.async {
            // Assuming you want to reload all rows
            let section = 0 // Modify this if you have multiple sections
            let numberOfRows = self.tblDataSources.numberOfRows(inSection: section)
            let indexPaths = (0..<numberOfRows).map { IndexPath(row: $0, section: section) }

            self.tblDataSources.reloadRows(at: indexPaths, with: .automatic)
            self.tblDataSources.refreshControl?.endRefreshing()
            
        }
    }
    

    func segueToManageDataSourceDetailsVC(source:String){
        self.segueSource = source
        if source == "Apple Health Data"{
            self.performSegue(withIdentifier: "goToManageAppleHealthVC", sender: self)
        }
        else{
            templateAlert(alertMessage: "No segue to \(source)")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToManageAppleHealthVC"){
            let manageAppleHealthVC = segue.destination as! ManageAppleHealthVC
            manageAppleHealthVC.userStore = self.userStore
            manageAppleHealthVC.requestStore = self.requestStore
            manageAppleHealthVC.appleHealthDataFetcher = self.appleHealthDataFetcher
            manageAppleHealthVC.healthDataStore = self.healthDataStore
        }
    }
    
}

extension ManageDataVC: UITableViewDelegate{
    
}

extension ManageDataVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userStore.arryDataSourceObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageDataTableCell", for: indexPath) as! ManageDataTableCell
        guard let arryDashHealthDataObj = userStore.arryDataSourceObjects else {return cell}
        let dashHealthDataObj = arryDashHealthDataObj[indexPath.row]
        let dataSourceText = dashHealthDataObj.name!
        let recordCountText = dashHealthDataObj.recordCount!
        cell.config(dataSource: dashHealthDataObj.name ?? "no name",recordCount:dashHealthDataObj.recordCount ?? "no records")
        cell.manageDataTableVCDelegate = self
        cell.indexPath = indexPath
        return cell
    }
    
}

protocol ManageDataVCDelegate{
    //    func showHistoryOptions(source:String)
//    func showHistoryOptions(forSource:String)
    func showSpinner()
    func removeSpinner()
    func segueToManageDataSourceDetailsVC(source:String)
}

class ManageDataTableCell: UITableViewCell{
    var manageDataTableVCDelegate : ManageDataVCDelegate!
    var stckVwMain = UIStackView()
    var stckVwLabels = UIStackView()
    var lblSourceName = UILabel()
    var lblRecordCount = UILabel()
    var btnRefresh = UIButton()
    var dataSource = ""
    var vwSpacerTop = UIView()
    var vwSpacer = UIView()
    var indexPath: IndexPath!
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(dataSource:String, recordCount:String) {
        self.dataSource = dataSource
        lblSourceName.text = self.dataSource
        lblSourceName.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblSourceName.translatesAutoresizingMaskIntoConstraints = false
        
        lblRecordCount.text = "Record Count: \(recordCount)"
        lblRecordCount.font = UIFont(name: "ArialRoundedMTBold", size: 12)
        lblRecordCount.translatesAutoresizingMaskIntoConstraints = false
        
        stckVwMain.axis = .horizontal
        stckVwLabels.axis = .vertical
        stckVwMain.accessibilityIdentifier = "stckVwMain"
        stckVwMain.translatesAutoresizingMaskIntoConstraints = false
        stckVwLabels.accessibilityIdentifier = "stckVwLabels"
        stckVwLabels.translatesAutoresizingMaskIntoConstraints = false
        
        vwSpacerTop.translatesAutoresizingMaskIntoConstraints = false
        vwSpacer.translatesAutoresizingMaskIntoConstraints = false
        
        
        // First add the stack view to the contentView
        contentView.addSubview(vwSpacerTop)
        contentView.addSubview(stckVwMain)
        contentView.addSubview(vwSpacer)
        
        // Then activate the constraints
        // Set constraints for vwSpacerTop
        vwSpacerTop.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 2.5)).isActive = true
        vwSpacerTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        vwSpacerTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        vwSpacerTop.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        
        
        vwSpacer.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 2.5)).isActive=true
        vwSpacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive=true
        vwSpacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive=true
        vwSpacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true  // This line was missing
        
        
        // Modify the stckVwMain top anchor constraint to attach to vwSpacerTop
        stckVwMain.topAnchor.constraint(equalTo: vwSpacerTop.bottomAnchor).isActive = true
        stckVwMain.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        stckVwMain.bottomAnchor.constraint(equalTo: vwSpacer.topAnchor).isActive = true
        stckVwMain.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        
        stckVwMain.addArrangedSubview(stckVwLabels)
        stckVwLabels.addArrangedSubview(lblSourceName)
        stckVwLabels.addArrangedSubview(lblRecordCount)
        
        // Button configuration
        btnRefresh.setTitle(" Refresh ", for: .normal)
        btnRefresh.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 12)
        btnRefresh.backgroundColor = .systemOrange
        btnRefresh.layer.cornerRadius = 10
        btnRefresh.translatesAutoresizingMaskIntoConstraints = false
        stckVwMain.addArrangedSubview(btnRefresh)
        btnRefresh.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnRefresh.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        btnRefresh.widthAnchor.constraint(equalToConstant: widthFromPct(percent: 25)).isActive=true
    }
    
    @objc func touchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
        
    }
    
    @objc func touchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        print("- in touchUpInside for \(dataSource)")
        self.manageDataTableVCDelegate.segueToManageDataSourceDetailsVC(source: dataSource)
        
    }
}
