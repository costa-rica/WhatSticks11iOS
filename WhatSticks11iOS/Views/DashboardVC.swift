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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Dashboard"
        print("- in DashboardVC viewDidLoad -")
        
        setup_btnGoToManageDataVC()
        if let _ = self.dashboardTableObject {
            dashboardTableObjectExists()

        }
        else{
            setup_btnRefreshDashboard()
        }
      

    }

    func dashboardTableObjectExists(){
        setup_lblDashboardTitle()
        tblDashboard = UITableView()
        setup_tbl()
        
        tblDashboard.delegate = self
        tblDashboard.dataSource = self
        tblDashboard.register(DashboardTableCell.self, forCellReuseIdentifier: "DashboardTableCell")
        tblDashboard.rowHeight = UITableView.automaticDimension
        tblDashboard.estimatedRowHeight = 100
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tblDashboard.refreshControl = refreshControl
        if let _ = btnRefreshDashboard{
            btnRefreshDashboard.removeFromSuperview()
        }
    }
    func setup_lblDashboardTitle(){
        lblDashboardTitle.text = self.dashboardTableObject!.name ?? "No title"
        lblDashboardTitle.font = UIFont(name: "ArialRoundedMTBold", size: 45)
        lblDashboardTitle.translatesAutoresizingMaskIntoConstraints = false
        lblDashboardTitle.accessibilityIdentifier="lblDashboardTitle"
        view.addSubview(lblDashboardTitle)
        lblDashboardTitle.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage/4)).isActive=true
        lblDashboardTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
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

    func setup_btnRefreshDashboard(){
        btnRefreshDashboard = UIButton()
        view.addSubview(btnRefreshDashboard)
        btnRefreshDashboard.translatesAutoresizingMaskIntoConstraints=false
        btnRefreshDashboard.accessibilityIdentifier="btnRefreshDashboard"
        btnRefreshDashboard.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnRefreshDashboard.addTarget(self, action: #selector(touchUpInside_btnRefreshDashboard(_:)), for: .touchUpInside)
        // vwFooter button Placement
        btnRefreshDashboard.bottomAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: -2)).isActive=true
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
            DispatchQueue.main.async {
                switch responseResult {
                case let .success(arryDashboardTableObjects):
                    print("- table update")
                    self.userStore.arryDashboardTableObjects = arryDashboardTableObjects
                    for obj in arryDashboardTableObjects{
                        if obj.name == self.lblDashboardTitle.text{
                            self.dashboardTableObject = obj
                            self.dashboardTableObjectExists()
                        }
                    }
                    self.userStore.writeObjectToJsonFile(object: arryDashboardTableObjects, filename: "arryDashboardTableObjects.json")
                case let .failure(error):
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if case UserStoreError.fileNotFound = error {
                            print("* file not found error *")
                            self.templateAlert(alertTitle: "Error", alertMessage: "Dashboard file not found")
                        } else {
                            
                            self.templateAlert(alertTitle: "Alert", alertMessage: "Failed to update data. Error: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        self.userStore.callSendDashboardTableObjects { responseResult in
            DispatchQueue.main.async {
                switch responseResult {
                case let .success(arryDashboardTableObjects):
                    print("- table updated")
                    self.userStore.arryDashboardTableObjects = arryDashboardTableObjects
                    for obj in arryDashboardTableObjects{
                        if obj.name == self.lblDashboardTitle.text{
                            self.dashboardTableObject = obj
//                            print("correaltion for stepcount: \(obj.arryIndepVarObjects![0].correlationValue)")
                        }
                    }
//                    self.userStore.writeDashboardJson()
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
        
//        guard let arryIndepVarObjects = dashboardTableObject.arryIndepVarObjects else {
//            return 0
//        }
//        return arryIndepVarObjects.count
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
        let indepVarObject = arryIndepVarObjects[indexPath.row]
        cell.setupLabels(indepVarName: indepVarObject.name ?? "no name", correlation: indepVarObject.correlationValue ?? "no value" )
        return cell
    }
    
}


class DashboardTableCell: UITableViewCell {

    // Properties
    var dblCorrelation: Double = 0.0 {
        didSet {
            let normalizedValue = CGFloat((dblCorrelation + 1) / 2) // Normalize between 0 and 1
            circleView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: normalizedValue, alpha: 1.0)
        }
    }

    let lblIndVar: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let lblCorrelation: UILabel = {
        let label = UILabel()
        // Configure label as needed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = heightFromPct(percent: 10) * 0.5 // Adjust as needed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        contentView.addSubview(lblIndVar)
        contentView.addSubview(circleView)
        contentView.addSubview(lblCorrelation)

        // Layout constraints
        NSLayoutConstraint.activate([
            // lblIndVar constraints
            lblIndVar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
            lblIndVar.centerYAnchor.constraint(greaterThanOrEqualTo: contentView.centerYAnchor), // Added top constraint

            // circleView constraints
            circleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -2)),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),
            circleView.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),

            // lblCorrelation constraints
            lblCorrelation.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            lblCorrelation.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Ensure that the bottom of the circleView is not clipped
            circleView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8) // Added bottom constraint
        ])
    }


    // Additional methods as needed
    func setupLabels(indepVarName:String, correlation:String){
        lblIndVar.text = indepVarName
        lblCorrelation.text = String(format: "%.2f", Double(correlation) ?? "No data")
//        guard var unwp_correlation = correlation else {return}
        dblCorrelation = Double(correlation) ?? 0.9
    }
}

