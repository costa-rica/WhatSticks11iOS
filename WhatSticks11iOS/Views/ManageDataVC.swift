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
//    var btnGoToManageDataVC=UIButton()
//    var btnGoToLoginVC=UIButton()
    var tblDataSources=UITableView()
    var segueSource:String?
    var btnGoToManageUser=UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupIsDev(urlStore: requestStore.urlStore)
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Manage Data"
//        self.setScreenNameFontSize(size: 30)
        tblDataSources.delegate = self
        tblDataSources.dataSource = self
        tblDataSources.register(ManageDataTableCell.self, forCellReuseIdentifier: "ManageDataTableCell")
        tblDataSources.rowHeight = UITableView.automaticDimension
        tblDataSources.estimatedRowHeight = 100
        setup_tbl()
        setup_btnGoToManageUser()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tblDataSources.refreshControl = refreshControl
        self.setScreenNameFontSize()
    }
    override func viewDidAppear(_ animated: Bool) {
        // MARK: There is an error here
//        for obj in userStore.arryDataSourceObjects!{
//            print("\(obj.name!): \(obj.recordCount!)")
//        }
//        DispatchQueue.main.async{
//            // Assuming you want to reload all rows
//            let section = 0 // Modify this if you have multiple sections
//            let numberOfRows = self.tblDataSources.numberOfRows(inSection: section)
//            let indexPaths = (0..<numberOfRows).map { IndexPath(row: $0, section: section) }
//            self.tblDataSources.reloadRows(at: indexPaths, with: .automatic)
//        }
    }// This tries to reload when data was added via AppleHealthDataVC
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        
        self.userStore.callSendDataSourceObjects { responseResult in
            switch responseResult{
            case let .success(arryDataSourceObjects):
                self.userStore.arryDataSourceObjects = arryDataSourceObjects
                self.userStore.writeObjectToJsonFile(object: arryDataSourceObjects, filename: "arryDataSourceObjects.json")
                self.refreshValuesInTable()
                self.refreshDashboardTableObjects()
            case .failure(_):
                print("No new data")
            }
        }
    }
    func refreshDashboardTableObjects(){
        self.userStore.callSendDashboardTableObjects { result in
            switch result{
            case let .success(arryDashboardTableObjects):
                self.userStore.arryDashboardTableObjects = arryDashboardTableObjects
                self.userStore.writeObjectToJsonFile(object: arryDashboardTableObjects, filename: "arryDashboardTableObjects.json")
            case .failure(_):
                print("no new DashboardTableObjects available yet.")
            }
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
            case let .success(arryDataSourceObjects):
                print("> ManageDataVC -- case let .success(arryDataSourceObjects):")
                self.userStore.arryDataSourceObjects = arryDataSourceObjects
                self.userStore.writeObjectToJsonFile(object: arryDataSourceObjects, filename: "arryDataSourceObjects.json")
                self.refreshValuesInTable()
                self.refreshDashboardTableObjects()
            case let .failure(error):
                print("> ManageDataVC -- case let .failure(error):")
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
    
    
    func setup_btnGoToManageUser(){
        view.addSubview(btnGoToManageUser)
        btnGoToManageUser.translatesAutoresizingMaskIntoConstraints=false
        btnGoToManageUser.accessibilityIdentifier="btnGoToManageUser"
        btnGoToManageUser.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnGoToManageUser.addTarget(self, action: #selector(touchUpInside_btnGoToManageUser(_:)), for: .touchUpInside)
        // vwFooter button Placement
        btnGoToManageUser.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        btnGoToManageUser.trailingAnchor.constraint(equalTo: vwFooter.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        btnGoToManageUser.backgroundColor = .systemBlue
        btnGoToManageUser.layer.cornerRadius = 10
        btnGoToManageUser.setTitle(" Manage User ", for: .normal)
    }
    @objc func touchUpInside_btnGoToManageUser(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        performSegue(withIdentifier: "goToManageUserVC", sender: self)
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
        else if (segue.identifier == "goToManageUserVC"){
            let manageUserVC = segue.destination as! ManageUserVC
            manageUserVC.userStore = self.userStore
            manageUserVC.requestStore = self.requestStore
            manageUserVC.healthDataStore = self.healthDataStore
            manageUserVC.appleHealthDataFetcher = self.appleHealthDataFetcher
        }
    }
    
}

extension ManageDataVC: UITableViewDelegate{
    
}

extension ManageDataVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("**********")
        print("userStore.arryDataSourceObjects?.count: \(userStore.arryDataSourceObjects?.count)")
        print("**********")
        return userStore.arryDataSourceObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageDataTableCell", for: indexPath) as! ManageDataTableCell
        guard let arryDataSourceObjects = userStore.arryDataSourceObjects else {return cell}
        cell.dataSourceObj = arryDataSourceObjects[indexPath.row]
        
        
        cell.config()
//        let dataSourceText = dashHealthDataObj.name!
//        let recordCountText = dashHealthDataObj.recordCount!
//        cell.config(dataSource: dashHealthDataObj.name ?? "no name",recordCount:dashHealthDataObj.recordCount ?? "no records")
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
    var dataSourceObj: DataSourceObject!
    var stckVwMain = UIStackView()
    var stckVwLabels = UIStackView()
    var lblSourceName = UILabel()
    var lblRecordCount = UILabel()
    var lblEarliestDate = UILabel()
    var btnAddDelete = UIButton()
//    var dataSource = ""
//    var vwSpacerTop = UIView()
//    var vwSpacer = UIView()
    var indexPath: IndexPath!
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        lblEarliestDate.removeFromSuperview()
        lblSourceName.removeFromSuperview()
        lblRecordCount.removeFromSuperview()
        stckVwLabels.removeFromSuperview()
        stckVwMain.removeFromSuperview()
        
    }
    
    func config(){
        lblSourceName.text = dataSourceObj.name
        lblSourceName.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblSourceName.translatesAutoresizingMaskIntoConstraints = false
        
        stckVwMain.axis = .horizontal
        stckVwLabels.axis = .vertical
        stckVwMain.accessibilityIdentifier = "stckVwMain"
        stckVwMain.translatesAutoresizingMaskIntoConstraints = false
        stckVwLabels.accessibilityIdentifier = "stckVwLabels"
        stckVwLabels.translatesAutoresizingMaskIntoConstraints = false
        
        // First add the stack view to the contentView
        contentView.addSubview(stckVwMain)
        
        stckVwMain.addArrangedSubview(stckVwLabels)
        stckVwLabels.addArrangedSubview(lblSourceName)
        
        // Button configuration
        btnAddDelete.setTitle(" Add/Delete ", for: .normal)
        btnAddDelete.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 12)
        btnAddDelete.backgroundColor = .systemOrange
        btnAddDelete.layer.cornerRadius = 10
        btnAddDelete.translatesAutoresizingMaskIntoConstraints = false
        stckVwMain.addArrangedSubview(btnAddDelete)
        btnAddDelete.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnAddDelete.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        btnAddDelete.widthAnchor.constraint(equalToConstant: widthFromPct(percent: 25)).isActive=true
        
        if let unwp_recordCount = dataSourceObj.recordCount {
            lblRecordCount.text = "Record Count: \(unwp_recordCount)"
            lblRecordCount.font = UIFont(name: "ArialRoundedMTBold", size: 12)
            lblRecordCount.translatesAutoresizingMaskIntoConstraints = false
            stckVwLabels.addArrangedSubview(lblRecordCount)
        }
        if let unwp_earliestDate = dataSourceObj.earliestRecordDate{
            lblEarliestDate.text = "Earliest Record: \(unwp_earliestDate)"
            lblEarliestDate.font = UIFont(name: "ArialRoundedMTBold", size: 12)
            lblEarliestDate.translatesAutoresizingMaskIntoConstraints = false
            stckVwLabels.addArrangedSubview(lblEarliestDate)
        }
        
        NSLayoutConstraint.activate([
            stckVwMain.topAnchor.constraint(equalTo: contentView.topAnchor,constant: heightFromPct(percent: 2.5)),
            stckVwMain.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stckVwMain.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: heightFromPct(percent: -2.5)),
            stckVwMain.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
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
//        print("- in touchUpInside for \(dataSource)")
        self.manageDataTableVCDelegate.segueToManageDataSourceDetailsVC(source: dataSourceObj.name ?? "missing")
        
    }
}
