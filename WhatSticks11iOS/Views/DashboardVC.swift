//
//  DashboardVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 08/12/2023.
//

import UIKit

class DashboardVC: TemplateVC, SelectDashboardVCDelegate{
    
    var userStore: UserStore!
    var requestStore: RequestStore!
    var appleHealthDataFetcher:AppleHealthDataFetcher!
    var healthDataStore:HealthDataStore!
    var btnGoToManageDataVC=UIButton()
    var tblDashboard:UITableView!
    var boolDashObjExists:Bool!
    var btnCheckDashTableObj = UIButton()
    var lblDashboardTitle=UILabel()
    var btnRefreshDashboard:UIButton!
    var btnTblDashboardOptions:UIButton?
    var btnDashboardTitleInfo:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupIsDev(urlStore: requestStore.urlStore)
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Dashboard"
        print("- in DashboardVC viewDidLoad -")
        setup_btnGoToManageDataVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        checkDashboardTableObject()
        //        if self.userStore.boolDashObjExists{
        //            self.dashboardTableObjectExists()
        //            self.lblDashboardTitle.text = self.userStore.currentDashboardObject!.dependentVarName
        //        } else {
        //            self.setup_btnRefreshDashboard()
        //            if let _ = self.tblDashboard{
        //                self.tblDashboard.removeFromSuperview()
        //                self.lblDashboardTitle.removeFromSuperview()
        //                self.btnDashboardTitleInfo.removeFromSuperview()
        //            }
        //            print("No arryDashboardTableObjects.json file found")
        //        }
    }
    
    //    func dashboardTableObjectExists(){
    func checkDashboardTableObject(){
        if self.userStore.boolDashObjExists{
            
            self.lblDashboardTitle.text = self.userStore.currentDashboardObject!.dependentVarName
            DispatchQueue.main.async {
                self.setup_lblDashboardTitle()
                self.btnDashboardTitleInfo = UIButton(type: .custom)
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
        }else {
            self.setup_btnRefreshDashboard()
            if let _ = self.tblDashboard{
                self.tblDashboard.removeFromSuperview()
                self.lblDashboardTitle.removeFromSuperview()
                self.btnDashboardTitleInfo.removeFromSuperview()
            }
            print("No arryDashboardTableObjects.json file found")
        }
    }
    func setup_lblDashboardTitle(){
        
        lblDashboardTitle.text = userStore.currentDashboardObject?.dependentVarName ?? "No title"
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
        let infoVC = InfoVC(dashboardTableObject: userStore.currentDashboardObject)
        infoVC.modalPresentationStyle = .overCurrentContext
        infoVC.modalTransitionStyle = .crossDissolve
        self.present(infoVC, animated: true, completion: nil)
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
        btnTblDashboardOptions.setTitle(" Dashboards ", for: .normal)
    }
    @objc func touchUpInside_btnTblDashboardOptions(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        //        let selectDashboardVC = SelectDashboardVC(arryDashboardTableObject: userStore.arryDashboardTableObjects)
        let selectDashboardVC = SelectDashboardVC(userStore: userStore)
        selectDashboardVC.delegate = self
        selectDashboardVC.modalPresentationStyle = .overCurrentContext
        selectDashboardVC.modalTransitionStyle = .crossDissolve
        self.present(selectDashboardVC, animated: true, completion: nil)
    }
    func setup_btnRefreshDashboard(){
        btnRefreshDashboard = UIButton()
        view.addSubview(btnRefreshDashboard)
        btnRefreshDashboard.translatesAutoresizingMaskIntoConstraints=false
        btnRefreshDashboard.accessibilityIdentifier="btnRefreshDashboard"
        btnRefreshDashboard.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnRefreshDashboard.addTarget(self, action: #selector(touchUpInside_btnRefreshDashboard(_:)), for: .touchUpInside)
        // vwFooter button Placement
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
        print("*--- self.userStore.arryDashboardTableObjects ---*")
        if self.userStore.arryDashboardTableObjects.count > 0 {
            print("count: \(self.userStore.arryDashboardTableObjects.count)")
            print("0 dependentVarName: \(self.userStore.arryDashboardTableObjects[0].dependentVarName!)")
            print("1 dependentVarName: \(self.userStore.arryDashboardTableObjects[1].dependentVarName!)")
        }
        self.userStore.callSendDashboardTableObjects { responseResult in
            switch responseResult {
            case let .success(arryDashboardTableObjects):
                print("- DashboardVC userStore.callSendDashboardTableObjects received SUCCESSFUL response")
                
                self.userStore.arryDashboardTableObjects = arryDashboardTableObjects
                if self.userStore.currentDashboardObjPos == nil {
                    self.userStore.currentDashboardObjPos = 0
                }
                self.userStore.currentDashboardObject = arryDashboardTableObjects[self.userStore.currentDashboardObjPos]
                self.userStore.boolDashObjExists = true
                self.userStore.writeObjectToJsonFile(object: arryDashboardTableObjects, filename: "arryDashboardTableObjects.json")
                self.checkDashboardTableObject()
                
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
                    self.userStore.writeObjectToJsonFile(object: arryDashboardTableObjects, filename: "arryDashboardTableObjects.json")
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
    
    //    func didSelectDashboard(dashboard: DashboardTableObject) {
    func didSelectDashboard(currentDashboardObjPos:Int){
        DispatchQueue.main.async{
            self.userStore.currentDashboardObjPos = currentDashboardObjPos
            self.userStore.currentDashboardObject = self.userStore.arryDashboardTableObjects[currentDashboardObjPos]
            self.lblDashboardTitle.text = self.userStore.arryDashboardTableObjects[currentDashboardObjPos].dependentVarName
            print("DashboardVC has a new self.dashboardTableObject")
            print("self.dashboardTableObject: \(self.userStore.currentDashboardObject!.dependentVarName)")
            // Update your view accordingly
            self.tblDashboard.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToManageDataVC"){
            let manageDataVC = segue.destination as! ManageDataVC
            manageDataVC.userStore = self.userStore
            manageDataVC.appleHealthDataFetcher = self.appleHealthDataFetcher
            manageDataVC.healthDataStore = self.healthDataStore
            manageDataVC.requestStore = self.requestStore
            
        }
        
    }
}

extension DashboardVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DashboardTableCell else { return }
        cell.isVisible.toggle()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}

extension DashboardVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dashTableObj = self.userStore.currentDashboardObject else {
            return 0
        }
        return dashTableObj.arryIndepVarObjects!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableCell", for: indexPath) as! DashboardTableCell
        guard let currentDashObj = userStore.currentDashboardObject,
              let arryIndepVarObjects = currentDashObj.arryIndepVarObjects,
              let unwpVerb = currentDashObj.verb else {return cell}

        cell.indepVarObject = arryIndepVarObjects[indexPath.row]
        cell.configureCellWithIndepVarObject()
        cell.depVarVerb = unwpVerb
        return cell
    }
    
}

protocol SelectDashboardVCDelegate{
    func didSelectDashboard(currentDashboardObjPos: Int)
}

class DashboardTableCell: UITableViewCell {
    
    // Properties
    var indepVarObject: IndepVarObject!
    var depVarVerb:String!
    var dblCorrelation: Double!
    var lblIndepVarName = UILabel()
    var lblIndVarObservationCount = UILabel()
    var vwCircle = UIView()
    var lblCorrelation = UILabel()
    var lblDefinition = UILabel()
    var lblWhatItMeansToYou = UILabel()
    var txtWhatItMeansToYou = String()
    
    // additional layout paramters
    var isVisible: Bool = false {
        didSet {
            lblCorrelation.isHidden = !isVisible
            stckVwClick.isHidden = !isVisible
            showLblDef()
            layoutIfNeeded()
        }
    }
    var lblDefinitionConstraints: [NSLayoutConstraint] = []
    var stckVwClick = UIStackView()
    //    var unclickedBottomConstraint: [NSLayoutConstraint] = []
    
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
        
        contentView.addSubview(lblIndepVarName)
        lblIndepVarName.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblIndepVarName.translatesAutoresizingMaskIntoConstraints = false
        lblIndepVarName.accessibilityIdentifier="lblIndepVarName"
        lblIndepVarName.numberOfLines = 0
        
        contentView.addSubview(vwCircle)
        vwCircle.backgroundColor = .systemBlue
        vwCircle.layer.cornerRadius = heightFromPct(percent: 10) * 0.5 // Adjust as needed
        vwCircle.translatesAutoresizingMaskIntoConstraints = false
        vwCircle.accessibilityIdentifier="vwCircle"
        
        contentView.addSubview(lblCorrelation)
        lblCorrelation.accessibilityIdentifier="lblCorrelation"
        lblCorrelation.isHidden = true
        lblCorrelation.translatesAutoresizingMaskIntoConstraints=false
        lblCorrelation.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            lblIndepVarName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
            lblIndepVarName.centerYAnchor.constraint(equalTo: vwCircle.centerYAnchor),
            lblIndepVarName.trailingAnchor.constraint(equalTo: vwCircle.leadingAnchor, constant: widthFromPct(percent: 1)),
            
            vwCircle.topAnchor.constraint(equalTo: contentView.topAnchor,constant: heightFromPct(percent: 2)),
            vwCircle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -2)),
            vwCircle.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: heightFromPct(percent: -2)),
            vwCircle.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),
            vwCircle.widthAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),
            
            lblCorrelation.centerXAnchor.constraint(equalTo: vwCircle.centerXAnchor),
            lblCorrelation.centerYAnchor.constraint(equalTo: vwCircle.centerYAnchor),
        ])
        contentView.addSubview(stckVwClick)
        stckVwClick.isHidden = true
        stckVwClick.accessibilityIdentifier = "stckVwClick"
        stckVwClick.axis = .vertical
        stckVwClick.spacing = heightFromPct(percent: 2)
        stckVwClick.translatesAutoresizingMaskIntoConstraints=false
        stckVwClick.addArrangedSubview(lblDefinition)
        stckVwClick.addArrangedSubview(lblWhatItMeansToYou)
        
        //        contentView.addSubview(lblDefinition)
        lblDefinition.accessibilityIdentifier="lblDefinition"
        //        lblDefinition.isHidden = true
        lblDefinition.translatesAutoresizingMaskIntoConstraints = false
        lblDefinition.font = UIFont(name: "ArialRoundedMTBold", size: 15)
        lblDefinition.numberOfLines = 0 // Enable multi-line
        
        //        contentView.addSubview(lblWhatItMeansToYou)
        lblWhatItMeansToYou.accessibilityIdentifier="lblWhatItMeansToYou"
        //        lblWhatItMeansToYou.isHidden = true
        lblWhatItMeansToYou.translatesAutoresizingMaskIntoConstraints = false
        lblWhatItMeansToYou.font = UIFont(name: "ArialRoundedMTBold", size: 15)
        lblWhatItMeansToYou.numberOfLines = 0 // Enable multi-line
        
    }
    
    
    // Additional methods as needed
    func configureCellWithIndepVarObject(){
        lblIndepVarName.text = indepVarObject.independentVarName
        createMultiFontDefinitionString()
        
        
        if let unwp_corr_value = indepVarObject.correlationValue {
            dblCorrelation = Double(unwp_corr_value)
            if dblCorrelation < 0.0{
                vwCircle.backgroundColor = UIColor.wsYellowFromDecimal(CGFloat(dblCorrelation))
            }
            else{
                vwCircle.backgroundColor = UIColor.wsBlueFromDecimal(CGFloat(dblCorrelation))
            }
            lblCorrelation.text = String(format: "%.2f", Double(unwp_corr_value) ?? 0.0)
            whatItMeansToYou()
            //            lblWhatItMeansToYou.text = txtWhatItMeansToYou
        }
    }
    func showLblDef() {
        if lblDefinitionConstraints.isEmpty {
            // Create constraints only once and store them
            lblDefinitionConstraints = [
                stckVwClick.topAnchor.constraint(equalTo: lblIndepVarName.bottomAnchor, constant: heightFromPct(percent: 4)),
                stckVwClick.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: heightFromPct(percent: -1)),
                stckVwClick.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
                stckVwClick.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -4)),
            ]
        }
        // Activate or deactivate constraints
        if isVisible {
            //            NSLayoutConstraint.deactivate(unclickedBottomConstraint)
            NSLayoutConstraint.activate(lblDefinitionConstraints)
            
        } else {
            NSLayoutConstraint.deactivate(lblDefinitionConstraints)
            //            NSLayoutConstraint.activate(unclickedBottomConstraint)
        }
    }
    func createMultiFontDefinitionString(){
        let boldUnderlinedText = "Definition:"
        let regularText = " " + (indepVarObject.definition ?? "<try reloading>")
        // Create an attributed string for the bold and underlined part
        let boldUnderlinedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let boldUnderlinedAttributedString = NSMutableAttributedString(string: boldUnderlinedText, attributes: boldUnderlinedAttributes)
        // Create an attributed string for the regular part
        let regularAttributedString = NSAttributedString(string: regularText)
        // Combine them
        boldUnderlinedAttributedString.append(regularAttributedString)
        // Set the attributed text to the label
        lblDefinition.attributedText = boldUnderlinedAttributedString
    }
    
    func whatItMeansToYou(){
        let strCorrelation = String(format: "%.2f", Double(dblCorrelation))
        var detailsText = String()
        if self.dblCorrelation > 0.25 {
            detailsText = "Since your sign here is positive \(strCorrelation) and closer to 1.0, this means as your \(self.indepVarObject.noun ?? "<try reloading screen>") increases you \(self.depVarVerb ?? "<try reloading screen>" ) more."
        }
        else if self.dblCorrelation > -0.25 {
            detailsText = "Since the value is close to 0.0, this means your \(self.indepVarObject.noun ?? "<try reloading screen>") doesn’t have much of an impact on how much you \(self.depVarVerb ?? "<try reloading screen>" )."
        } else {
            detailsText = "Since your sign here is negative \(strCorrelation) and closer to -1.0, this means as your \(self.indepVarObject.noun ?? "<try reloading screen>") increases you \(self.depVarVerb ?? "<try reloading screen>" ) less."
        }
        let boldUnderlinedText = "For you:"
        let regularText = " " + detailsText
        // Create an attributed string for the bold and underlined part
        let boldUnderlinedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let boldUnderlinedAttributedString = NSMutableAttributedString(string: boldUnderlinedText, attributes: boldUnderlinedAttributes)
        // Create an attributed string for the regular part
        let regularAttributedString = NSAttributedString(string: regularText)
        // Combine them
        boldUnderlinedAttributedString.append(regularAttributedString)
        // Set the attributed text to the label
        lblWhatItMeansToYou.attributedText = boldUnderlinedAttributedString
    }
}


