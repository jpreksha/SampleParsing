//
//  WelcomeViewController.swift
//  SampleParsing
//
//  Created by Preksha Jaiswal on 12/3/18.
//  Copyright © 2018 Infor. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    var webServiceManager: WebServiceManager = WebServiceManager()
    
    @IBOutlet weak var loadButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadButton.setTitle("Welcome to my World", for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loadBooks(_ sender: Any) {
        self.webServiceManager.loadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
