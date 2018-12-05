//
//  HomeViewController.swift
//  QualityInspections
//
//  Created by Neeraj Rachamalla on 7/26/17.
//  Copyright © 2017 Infor. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeViewController: BaseViewController,MoreViewDelegate,WebServiceManagerDelegate,ToolbarForHomeDelegate,ChooseSortedItemDelegate {

    let webServiceManager:WebServiceManager = WebServiceManager()
    static var needsADataRefetch:Bool = false
    
    @IBOutlet weak var noDataAvailable: UILabel!
    @IBOutlet weak var toolBarForHome: ToolBarForHome!
    @IBOutlet weak var inspectionOrderTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.!
        print("Home View Controller set as root Base URL :\(BaseDataManager.sharedInstance.WebServiceBaseURl!)")
        webServiceManager.delegate = self
        toolBarForHome.delegate = self
        self.webServiceManager.fetchUserData()
        inspectionOrderTableView.tableFooterView = UIView(frame: CGRect.zero)
        inspectionOrderTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.title = LanguageHelper.getLocalizedString(forKey: "inspectionOrders")
        BaseDataManager.sharedInstance.resetPeriodNavigationsToCurrentPeriod()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if HomeViewController.needsADataRefetch == true {
            self.webServiceManager.fetchInspectionOrders()
            HomeViewController.needsADataRefetch = false
        }
    }

    class func setAsRootViewController()->Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var vc = appDelegate.window?.rootViewController
        
        if vc is UINavigationController{
            vc = (vc as! UINavigationController).viewControllers[0]
            if(vc is HomeViewController){
                print("Root View already set")
            }else{
                let storyboard = UIStoryboard(name: Main_StoryBoard_Name, bundle: nil)
                let controller_Home = storyboard.instantiateViewController(withIdentifier: "HomeNavigationViewStoryBoardID")
                vc = (controller_Home as! UINavigationController).viewControllers[0]
                vc?.navigationItem.leftBarButtonItem = nil
                for view in appDelegate.window!.subviews{
                    view.removeFromSuperview()
                }
                appDelegate.window!.rootViewController?.view.removeFromSuperview()
                Utilities.delay(0.25) {
                    appDelegate.window?.rootViewController = controller_Home
                    appDelegate.window?.makeKeyAndVisible()
                }
            }
        }else{
            let storyboard = UIStoryboard(name: Main_StoryBoard_Name, bundle: nil)
            let controller_Home = storyboard.instantiateViewController(withIdentifier: "HomeNavigationViewStoryBoardID")
            vc = (controller_Home as! UINavigationController).viewControllers[0]
            vc?.navigationItem.leftBarButtonItem = nil
            for view in appDelegate.window!.subviews{
                view.removeFromSuperview()
            }
            appDelegate.window!.rootViewController?.view.removeFromSuperview()
            Utilities.delay(0.25) {
                appDelegate.window?.rootViewController = controller_Home
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    func checkIfBasicConfigurationIsDoneElseNavigateToSettings(){
        let company = BaseDataManager.sharedInstance.getCompanyID()
        if company.count == 0{
            self.navigateToSettings(fetchInitialData: true)
            HomeViewController.needsADataRefetch = true
        }else{
            self.webServiceManager.fetchInitialData()
        }
    }
    
    @IBAction func MoreClicked(_ sender: UIBarButtonItem) {
        self.navigateToSettings(fetchInitialData: false)
    }
    
    func navigateToSettings(fetchInitialData:Bool)->Void{
        let storyboard = UIStoryboard(name: Main_StoryBoard_Name, bundle: nil)
        let viewController:MoreViewController = storyboard.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        viewController.delegate = self
        viewController.webServiceManager.delegate = viewController
        viewController.fetchInitialData = fetchInitialData
        if UIDevice.current.userInterfaceIdiom == .pad{
            let navVC = UINavigationController.init(rootViewController: viewController)
            navVC.modalPresentationStyle = .formSheet
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon_close"), style: UIBarButtonItemStyle.plain, target: viewController, action: #selector(viewController.closeSettings))
            self.present(navVC, animated: true, completion: nil)
        }else{
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:LanguageHelper.getLocalizedString(forKey: ""), style:.plain, target:nil, action:nil)
            self.navigationController?.show(viewController, sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - WebServiceManagerDelegate
    
    func CompletedFetchingInitialData(parsedOnlyForWareHousesAndWorkCenters: Bool) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.appDelegate.window!, animated: true)
            self.webServiceManager.fetchInspectionOrders()
        }
    }
    
    func CompletedFetchingInspectionOrders() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.appDelegate.window!, animated: true)
            if BaseDataManager.sharedInstance.inspectionOrders.count == 0 {
                self.noDataAvailable.text = LanguageHelper.getLocalizedString(forKey: "noDataAvailable")
                self.noDataAvailable.isHidden = false
            }else{
                self.noDataAvailable.text = ""
                self.noDataAvailable.isHidden = true
            }
            self.inspectionOrderTableView.reloadData()
            self.toolBarForHome.setToolBarText()
        }
        let inspectionOrders = BaseDataManager.sharedInstance.inspectionOrders
        for inspectionOrder in inspectionOrders{
            print(inspectionOrder.inspectionID)
        }
    }
    
    func CompletedFetchingUserData() {
        let configDict: NSDictionary? = oauthHelper.getConfigDict()
        
        if let userName = User.sharedInstance.userName {
            if configDict != nil{
                SSODataManager.sharedInstance().addUserData(forServer: configDict?.value(forKey: "ev") as! String, tenant: configDict?.value(forKey: "ti") as! String, userName: userName, displayPictureData: User.sharedInstance.userProfileImageData, withSuccessBlock: { (userName) in
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.appDelegate.window!, animated: true)
                        self.checkIfBasicConfigurationIsDoneElseNavigateToSettings()
                    }
                }, fail: { (error) in
                    print(error!)
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.appDelegate.window!, animated: true)
                        self.checkIfBasicConfigurationIsDoneElseNavigateToSettings()
                    }
                })
            }else{
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.appDelegate.window!, animated: true)
                    self.checkIfBasicConfigurationIsDoneElseNavigateToSettings()
                }
            }
            
        }else{
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.appDelegate.window!, animated: true)
                self.checkIfBasicConfigurationIsDoneElseNavigateToSettings()
            }
        }
    }
    
    //MARK: - MoreViewDelegate
    
    func didFinishLogout(status: Bool) {
       
    }
    
    func didChangeCompanyID(status: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad && HomeViewController.needsADataRefetch == true {
            self.webServiceManager.fetchInspectionOrders()
            HomeViewController.needsADataRefetch = false
        }
    }
    
    func getCompletedCount(inspectionLines:[InspectionOrderLine])->Int{
        var completedCount = 0
        for line in inspectionLines{
            if line.status == "completed"{
                completedCount += 1
            }
        }
        return completedCount
    }
    
    // MARK: - Home Toolbar Delegate
    
    //Next Period
    func periodIncremented() {
        LogHelper.track("")
        BaseDataManager.sharedInstance.getNextPeriod { (status) in
            self.webServiceManager.fetchInspectionOrders()
        }
    }
    
    //Previous Period
    func periodDecremented() {
        LogHelper.track("")
        BaseDataManager.sharedInstance.getPreviousPeriod { (status) in
            self.webServiceManager.fetchInspectionOrders()
        }
    }
    
    func refreshClicked() {
        self.webServiceManager.fetchInspectionOrders()
    }
  
    // MARK: - Choose Sorted Option Delegate
    
    func didFinishSelectingSortedOptions(selectedOption: String, selectedInspectionOderIndex: Int) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:LanguageHelper.getLocalizedString(forKey: ""), style:.plain, target:nil, action:nil)

        let inspectionOrder = BaseDataManager.sharedInstance.inspectionOrders[selectedInspectionOderIndex]
        // Directly navigate to Entering Test data
        let storyboard = UIStoryboard(name: Main_StoryBoard_Name, bundle: nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailsVC.inspectionOrder = inspectionOrder
        detailsVC.selectedSample = selectedOption
        
        self.navigationController?.show(detailsVC, sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        return true
//    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return BaseDataManager.sharedInstance.inspectionOrders.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad{
            return 44
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inspectionOrderCell") as! InspectionOrderCell
        let inspectionOrder = BaseDataManager.sharedInstance.inspectionOrders[indexPath.row]
        if inspectionOrder.result == "accepted"{
            cell.statusImageView.image = UIImage(named: "good")
        }else{
            cell.statusImageView.layer.masksToBounds = true
            cell.statusImageView.layer.cornerRadius = 9
            cell.statusImageView.backgroundColor = UIColor.Graphite.graphite05
        }
        cell.inspectionOrderID?.text = inspectionOrder.inspectionOrderID
        cell.itemID?.text = inspectionOrder.item.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.originName?.text = BaseDataManager.sharedInstance.getOriginDescription(fromID: inspectionOrder.orderOrigin)
        cell.originOrderID?.text = inspectionOrder.orderNumber
        let completedCount = self.getCompletedCount(inspectionLines: inspectionOrder.inspectionOrderLines)
        cell.linesCompletedLabel?.text = "\(completedCount) of \(inspectionOrder.inspectionOrderLines.count) Completed"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let inspectionOrder = BaseDataManager.sharedInstance.inspectionOrders[indexPath.row]
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target:nil, action:nil)

        //get list of samples
        let options = BaseDataManager.sharedInstance.getListOfSortedOptions(forInspectionOrder: BaseDataManager.sharedInstance.inspectionOrders[indexPath.row])
        
        if options.count > 1{
            let storyboard = UIStoryboard(name: Main_StoryBoard_Name, bundle: nil)
            let sortVC = storyboard.instantiateViewController(withIdentifier: "ChooseSortedItemViewController") as! ChooseSortedItemViewController
            sortVC.selectedInspectionOrderIndex = indexPath.row
            sortVC.listOfOption = options
            if UIDevice.current.userInterfaceIdiom == .pad{
                let navVC = UINavigationController.init(rootViewController: sortVC)
                navVC.modalPresentationStyle = .formSheet
                sortVC.delegate = self
                sortVC.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon_close"), style: UIBarButtonItemStyle.plain, target: sortVC, action: #selector(sortVC.closeSettings))
                self.present(navVC, animated: true, completion: nil)
            }else{
                self.navigationController?.show(sortVC, sender: nil)
            }
        }else if options.count == 1{// Directly navigate to Entering Test data
            // Directly navigate to Entering Test data
            let storyboard = UIStoryboard(name: Main_StoryBoard_Name, bundle: nil)
            let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            detailsVC.inspectionOrder = inspectionOrder
            detailsVC.selectedSample = options[0]
            self.navigationController?.show(detailsVC, sender: nil)
        }else{
            CommonUIHelper.sharedInstance.showTimeOutMessage(message: LanguageHelper.getLocalizedString(forKey: "noDataAvailable"))
        }
    }
}
