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

    var tblDashboard = UITableView()
    var arryDashDataDict = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Dashboard"
        print("- in DashboardVC viewDidLoad -")
        setup_btnGoToManageDataVC()
        setup_tbl()
        tblDashboard.delegate = self
        tblDashboard.dataSource = self
        tblDashboard.register(DashboardTableCell.self, forCellReuseIdentifier: "DashboardTableCell")
        tblDashboard.rowHeight = UITableView.automaticDimension
        tblDashboard.estimatedRowHeight = 100
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tblDashboard.refreshControl = refreshControl
    }
    func setup_arryDashDataDict(){
        if let unwp_arry = self.userStore.arryDashHealthDataObj{
            for obj in unwp_arry {
                if  obj.name == "Apple Health Data"{
                    if let unwp_arryDataDict = obj.arryDataDict{
                        arryDashDataDict = unwp_arryDataDict
                    }
                }
            }
        }
    }

    func setup_tbl(){
        tblDashboard.accessibilityIdentifier = "tblDashboard"
        tblDashboard.translatesAutoresizingMaskIntoConstraints=false
        view.addSubview(tblDashboard)
        tblDashboard.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: 5)).isActive=true
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

    @objc private func refreshData(_ sender: UIRefreshControl) {
        self.userStore.callSendHealthDataObjects(login: false) { responseResult in
            DispatchQueue.main.async {
                switch responseResult {
                case let .success(arryDashHealthDataObj):
                    self.userStore.arryDashHealthDataObj = arryDashHealthDataObj
                    self.setup_arryDashDataDict() // Updates data array
                    self.tblDashboard.reloadData() // Reloads table view
                    sender.endRefreshing()

                case let .failure(error):
                    sender.endRefreshing() // Stop refreshing before showing alert

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.templateAlert(alertTitle: "Alert", alertMessage: "Failed to update data. Error: \(error)")
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

        return arryDashDataDict.count-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableCell", for: indexPath) as! DashboardTableCell
//        let indVarName = self.arryDashDataDict[""]
        cell.setupLabels(indepVarName: "Daily Steps", correlation: self.arryDashDataDict[0]["Daily Steps"] ?? "no value" )
        return cell
    }
    
}


class DashboardTableCell: UITableViewCell {

    // Properties
    var dblCorrelation: Double = 0.0 {
        didSet {
            // Update the circle color based on dblCorrelation value
            // This is just a placeholder, you can modify the logic as needed
            circleView.backgroundColor = dblCorrelation > 0.5 ? .systemBlue : .systemGreen
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
        view.layer.cornerRadius = 10 // Adjust as needed
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
        addSubview(lblIndVar)
        addSubview(circleView)
        addSubview(lblCorrelation)

        // Layout constraints
        NSLayoutConstraint.activate([
            // lblIndVar constraints
            lblIndVar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            lblIndVar.centerYAnchor.constraint(equalTo: centerYAnchor),

            // circleView constraints
            circleView.leadingAnchor.constraint(equalTo: lblIndVar.trailingAnchor, constant: 8),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 20), // Adjust size as needed
            circleView.heightAnchor.constraint(equalToConstant: 20),

            // lblCorrelation constraints
            lblCorrelation.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 8),
            lblCorrelation.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // Additional methods as needed
    func setupLabels(indepVarName:String, correlation:String){
        lblIndVar.text = indepVarName
        lblCorrelation.text = correlation
    }
}

