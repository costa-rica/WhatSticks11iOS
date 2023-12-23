//
//  DashboardVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 08/12/2023.
//

import UIKit

class DashboardVC: TemplateVC{
    
    var userStore: UserStore!
    var requestStore: RequestStore!
    var appleHealthDataFetcher:AppleHealthDataFetcher!
    var healthDataStore:HealthDataStore!
    var btnGoToManageDataVC=UIButton()
    var tblDashboard:UITableView!
    var dashboardTableObject: DashboardTableObject?
    var btnCheckDashTableObj = UIButton()
    var lblDashboardTitle=UILabel()
    var btnRefreshDashboard:UIButton!
    var btnTblDashboardOptions:UIButton?
    var boolTblDashboardOptions:Bool = false
    var btnDashboardTitleInfo = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Dashboard"
        print("- in DashboardVC viewDidLoad -")
        setup_btnGoToManageDataVC()
        

    }
    override func viewWillAppear(_ animated: Bool) {

        userStore.checkDashboardJson { result in
//            print("* checking: userStore.checkDashboardJson")
            DispatchQueue.main.async{
                switch result{
                case .success(_):
                    if let unwp_arryDashTableObj = self.userStore.arryDashboardTableObjects{
//                        print("- found self.userStore.arryDashboardTableObjects")
                        self.dashboardTableObject = unwp_arryDashTableObj[0]
                        self.dashboardTableObjectExists()
                    }
                    else{
                        print("- did not find self.userStore.arryDashboardTableObjects")
                        self.templateAlert(alertTitle: "Error", alertMessage: "Something wrong with viewWillAppear DashboardVC")
                        self.setup_btnRefreshDashboard()
                    }
                case let .failure(error):
                    self.setup_btnRefreshDashboard()
                    if let _ = self.tblDashboard{
                        self.tblDashboard.removeFromSuperview()
                        self.lblDashboardTitle.removeFromSuperview()
                    }
                    print("No arryDashboardTableObjects.json file found, error: \(error)")
                }
            }
        }
    }

    func dashboardTableObjectExists(){
        DispatchQueue.main.async {
            self.setup_lblDashboardTitle()
            self.setupInformationButton()
            self.setup_btnTblDashboardOptions()
            self.tblDashboard = UITableView()
            self.setup_tbl()
            self.tblDashboard.delegate = self
            self.tblDashboard.dataSource = self
            self.tblDashboard.register(DashboardTableCell.self, forCellReuseIdentifier: "DashboardTableCell")
            self.tblDashboard.rowHeight = UITableView.automaticDimension
            self.tblDashboard.estimatedRowHeight = 100
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
            self.tblDashboard.refreshControl = refreshControl
            
            if let _ = self.btnRefreshDashboard{
                self.btnRefreshDashboard.removeFromSuperview()
            }
        }
    }
    func setup_lblDashboardTitle(){
        lblDashboardTitle.text = self.dashboardTableObject!.dependentVarName ?? "No title"
        lblDashboardTitle.font = UIFont(name: "ArialRoundedMTBold", size: 45)
        lblDashboardTitle.translatesAutoresizingMaskIntoConstraints = false
        lblDashboardTitle.accessibilityIdentifier="lblDashboardTitle"
        view.addSubview(lblDashboardTitle)
        lblDashboardTitle.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage/4)).isActive=true
        lblDashboardTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
    }
    private func setupInformationButton() {
        if let unwrapped_image = UIImage(named: "information") {
            let small_image = unwrapped_image.scaleImage(toSize: CGSize(width: 10, height: 10))
            // Set the image for the button
            btnDashboardTitleInfo.setImage(small_image, for: .normal)
            // Add action for button
            btnDashboardTitleInfo.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
            // Add the button to the view
            self.view.addSubview(btnDashboardTitleInfo)
            btnDashboardTitleInfo.translatesAutoresizingMaskIntoConstraints=false
            btnDashboardTitleInfo.leadingAnchor.constraint(equalTo: lblDashboardTitle.trailingAnchor,constant: widthFromPct(percent: 0.5)).isActive=true
            btnDashboardTitleInfo.centerYAnchor.constraint(equalTo: lblDashboardTitle.centerYAnchor, constant: heightFromPct(percent: -2)).isActive=true
            
        }

    }
    @objc private func infoButtonTapped() {
        print("button pressed")
//        if let unwp_def = dashboardTableObject?.definition{
        let infoVC = InfoVC(dashboardTableObject: self.dashboardTableObject)
        infoVC.modalPresentationStyle = .overCurrentContext
        infoVC.modalTransitionStyle = .crossDissolve
        self.present(infoVC, animated: true, completion: nil)
//        }
    }
    
    
    func setup_tbl(){
        tblDashboard.accessibilityIdentifier = "tblDashboard"
        tblDashboard.translatesAutoresizingMaskIntoConstraints=false
        view.addSubview(tblDashboard)
        tblDashboard.topAnchor.constraint(equalTo: lblDashboardTitle.bottomAnchor, constant: heightFromPct(percent: 2)).isActive=true
        tblDashboard.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        tblDashboard.bottomAnchor.constraint(equalTo: vwFooter.topAnchor).isActive=true
        tblDashboard.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        tblDashboard.translatesAutoresizingMaskIntoConstraints=false
    }
    func setup_btnGoToManageDataVC(){
        view.addSubview(btnGoToManageDataVC)
        btnGoToManageDataVC.translatesAutoresizingMaskIntoConstraints=false
        btnGoToManageDataVC.accessibilityIdentifier="btnGoToManageDataVC"
        btnGoToManageDataVC.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnGoToManageDataVC.addTarget(self, action: #selector(touchUpInside_goToManageDataVC(_:)), for: .touchUpInside)
        // vwFooter button Placement
        btnGoToManageDataVC.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        btnGoToManageDataVC.trailingAnchor.constraint(equalTo: vwFooter.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        btnGoToManageDataVC.backgroundColor = .systemBlue
        btnGoToManageDataVC.layer.cornerRadius = 10
        btnGoToManageDataVC.setTitle(" Manage Data ", for: .normal)
    }
    @objc func touchUpInside_goToManageDataVC(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        performSegue(withIdentifier: "goToManageDataVC", sender: self)

    }
    
    func setup_btnTblDashboardOptions(){
        btnTblDashboardOptions = UIButton()
        guard let btnTblDashboardOptions = btnTblDashboardOptions else {return}
        view.addSubview(btnTblDashboardOptions)
        btnTblDashboardOptions.translatesAutoresizingMaskIntoConstraints=false
        btnTblDashboardOptions.accessibilityIdentifier="btnTblDashboardOptions"
        btnTblDashboardOptions.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnTblDashboardOptions.addTarget(self, action: #selector(touchUpInside_btnTblDashboardOptions(_:)), for: .touchUpInside)
        // vwFooter button Placement
        btnTblDashboardOptions.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        btnTblDashboardOptions.leadingAnchor.constraint(equalTo: vwFooter.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        btnTblDashboardOptions.backgroundColor = .systemBlue
        btnTblDashboardOptions.layer.cornerRadius = 10
        btnTblDashboardOptions.setTitle(" Dashboard Labels ", for: .normal)
    }
    @objc func touchUpInside_btnTblDashboardOptions(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        boolTblDashboardOptions.toggle()
        for cell in tblDashboard.visibleCells as! [DashboardTableCell] {
//            cell.setupOptionalElements(areVisible: boolTblDashboardOptions)
            cell.updateVisibility(isVisible: boolTblDashboardOptions)
        }
    }
    
    
    func setup_btnRefreshDashboard(){
        btnRefreshDashboard = UIButton()
        view.addSubview(btnRefreshDashboard)
        btnRefreshDashboard.translatesAutoresizingMaskIntoConstraints=false
        btnRefreshDashboard.accessibilityIdentifier="btnRefreshDashboard"
        btnRefreshDashboard.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnRefreshDashboard.addTarget(self, action: #selector(touchUpInside_btnRefreshDashboard(_:)), for: .touchUpInside)
        // vwFooter button Placement
//        btnRefreshDashboard.bottomAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: -15)).isActive=true
        btnRefreshDashboard.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive=true
        btnRefreshDashboard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        btnRefreshDashboard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        btnRefreshDashboard.backgroundColor = .systemGray
        btnRefreshDashboard.layer.cornerRadius = 10
        btnRefreshDashboard.setTitle(" Refresh Table ", for: .normal)
    }
    @objc func touchUpInside_btnRefreshDashboard(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        
        self.userStore.callSendDashboardTableObjects { responseResult in
                switch responseResult {
                case let .success(arryDashboardTableObjects):
                    print("- DashboardVC userStore.callSendDashboardTableObjects received SUCCESSFUL response")
                    self.userStore.arryDashboardTableObjects = arryDashboardTableObjects
                    for obj in arryDashboardTableObjects{
                        if obj.dependentVarName == "Sleep Time"{
                            self.dashboardTableObject = obj
                            self.dashboardTableObjectExists()
                        }
                    }
                    self.userStore.writeObjectToJsonFile(object: arryDashboardTableObjects, filename: "arryDashboardTableObjects.json")
                case let .failure(error):
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if case UserStoreError.fileNotFound = error {
                            print("* file not found error *")
                            self.templateAlert(alertTitle: "", alertMessage: "No data exists. Go to Manage Data to add data for your dashboard.")
                        } else {
                            self.templateAlert(alertTitle: "Alert", alertMessage: "Failed to update data. Error: \(error)")
                        }
                    }
                }
        }
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {

        self.userStore.callSendDataSourceObjects { responseResult in
            switch responseResult{
            case let .success(arryDataSourceObjects):
                self.userStore.arryDataSourceObjects = arryDataSourceObjects
                self.userStore.writeObjectToJsonFile(object: arryDataSourceObjects, filename: "arryDataSourceObjects.json")
//                self.refreshValuesInTable()
                self.refreshDashboardTableObjects(sender)
            case .failure(_):
                print("No new data")
                self.refreshDashboardTableObjects(sender)
            }
        }
    }

    func refreshDashboardTableObjects(_ sender: UIRefreshControl){
        self.userStore.callSendDashboardTableObjects { responseResult in
            DispatchQueue.main.async {
                switch responseResult {
                case let .success(arryDashboardTableObjects):
                    print("- table updated")
                    self.userStore.arryDashboardTableObjects = arryDashboardTableObjects
                    for obj in arryDashboardTableObjects{
                        if obj.dependentVarName == self.lblDashboardTitle.text{
                            self.dashboardTableObject = obj
//                            print("successfully recieved arryDashboardTableObjects from API")
//                            print("correaltion for stepcount: \(obj.arryIndepVarObjects![0].correlationValue)")
                        }
                    }
                    self.userStore.writeObjectToJsonFile(object: arryDashboardTableObjects, filename: "arryDashboardTableObjects.json")
                    //self.setup_arryDashDataDict() // Updates data array
                    self.tblDashboard.reloadData() // Reloads table view
                    sender.endRefreshing()

                case let .failure(error):
                    sender.endRefreshing() // Stop refreshing before showing alert
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if case UserStoreError.fileNotFound = error {
                            print("* file not found error *")
                            self.templateAlert(alertTitle: "Error", alertMessage: "Dashboard file not found")
                        } else {
                            print("* failed to arryDashboardTableObjects from API *")
                            self.templateAlert(alertTitle: "Alert", alertMessage: "Failed to update data. Error: \(error)")
                        }
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToManageDataVC"){
            let manageDataVC = segue.destination as! ManageDataVC
            manageDataVC.userStore = self.userStore
            manageDataVC.appleHealthDataFetcher = self.appleHealthDataFetcher
            manageDataVC.healthDataStore = self.healthDataStore

        }

    }
}

extension DashboardVC: UITableViewDelegate{
    
}

extension DashboardVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let arryIndVarObj = userStore.arryDashboardTableObjects else {
            return 0
        }
        return arryIndVarObj[0].arryIndepVarObjects!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableCell", for: indexPath) as! DashboardTableCell
        guard let arryIndepVarObjects = dashboardTableObject!.arryIndepVarObjects else {
            print("- in cellForRowAt failed to get dashboardTableObject.arryIndepVarObjects ")
            return cell
        }
//        let indepVarObject = arryIndepVarObjects[indexPath.row]
//        cell.setupLabels(indepVarName: indepVarObject.name ?? "no name", correlation: indepVarObject.correlationValue ?? "no value", observationCount: indepVarObject.correlationObservationCount ?? "no correlation count" )
        cell.indepVarObject = arryIndepVarObjects[indexPath.row]
        cell.setupLabels()
        return cell
    }
    
}


class DashboardTableCell: UITableViewCell {

    // Properties
    var indepVarObject: IndepVarObject!
    var dblCorrelation: Double!
    var lblIndVar = UILabel()
    var lblIndVarObservationCount = UILabel()
    var lblCorrelation = UILabel()
    var vwCircle = UIView()

    // Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup views and constraints
    private func setupViews() {
        
        vwCircle.backgroundColor = .systemBlue
        vwCircle.layer.cornerRadius = heightFromPct(percent: 10) * 0.5 // Adjust as needed
        vwCircle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vwCircle)
        
        lblIndVar.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblIndVar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lblIndVar)
        
        lblCorrelation.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(lblCorrelation)
        
//        lblIndVarObservationCount.font = UIFont(name: "ArialRoundedMTBold", size: 13)
//        lblIndVarObservationCount.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.addSubview(lblIndVarObservationCount)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            
            // lblIndVar constraints
            lblIndVar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
            lblIndVar.centerYAnchor.constraint(greaterThanOrEqualTo: contentView.centerYAnchor), // Added top constraint
            
//            // lblIndVar constraints
//            lblIndVarObservationCount.topAnchor.constraint(equalTo: self.lblIndVar.bottomAnchor, constant: heightFromPct(percent: 1)),
//            lblIndVarObservationCount.leadingAnchor.constraint(equalTo: self.lblIndVar.leadingAnchor),

            // vwCircle constraints
            vwCircle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -2)),
            vwCircle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            vwCircle.widthAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),
            vwCircle.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),
            
            // lblCorrelation constraints
            lblCorrelation.centerXAnchor.constraint(equalTo: self.vwCircle.centerXAnchor),
            lblCorrelation.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            // Ensure that the bottom of the circleView is not clipped
            vwCircle.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8) // Added bottom constraint
        ])
    }

    // Additional methods as needed
//    func setupLabels(indepVarName:String, correlation:String,observationCount: String){
    func setupLabels(){
        lblIndVar.text = indepVarObject.independentVarName
//        dblCorrelation = Double(indepVarObject.correlationValue) ?? 0.9
        //        self.observationCount = observationCount
        if let unwp_corr_value = indepVarObject.correlationValue {
            if let unwp_float = Double(unwp_corr_value){
                if unwp_float < 0.0{
                    vwCircle.backgroundColor = UIColor.wsYellowFromDecimal(CGFloat(unwp_float))
                }
                else{
                    vwCircle.backgroundColor = UIColor.wsBlueFromDecimal(CGFloat(unwp_float))
                }
            }
        }
    }
    
    func updateVisibility(isVisible: Bool) {
        guard let unwp_correlationValue = indepVarObject.correlationValue else {return}
        lblCorrelation.text = isVisible ? String(format: "%.2f", Double(unwp_correlationValue) ?? 0.0) : ""
    }
}


