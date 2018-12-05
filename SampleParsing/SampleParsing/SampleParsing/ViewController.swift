//
//  ViewController.swift
//  SampleParsing
//
//  Created by Preksha Jaiswal on 05/09/1940 .
//  Copyright © 1940 Infor. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    @IBOutlet weak var booksTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        booksTableView.delegate = self
        booksTableView.dataSource = self
    }
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BooksParser.sharedInstance.booksData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        configureCell(Cell:cell!,index:indexPath)
        return cell!
    }
    
    func  configureCell(Cell:UITableViewCell,index:IndexPath){
        var data = BooksParser.sharedInstance.booksData
        let booksInfo = data[index.row]
        Cell.textLabel?.text = booksInfo.title
        Cell.detailTextLabel?.text = booksInfo.author
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
