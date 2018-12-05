//
//  WebServiceManager.swift
//  SampleParsing
//
//  Created by Preksha Jaiswal on 12/3/18.
//  Copyright © 2018 Infor. All rights reserved.
//

import UIKit

protocol WebServiceManagerDelegate {
    func completedParsing()
}
class WebServiceManager: NSObject,URLSessionDelegate,BooksParserDelegate {

    func loadData() -> Void {
        let path = Bundle.main.url(forResource: "Books", withExtension: "xml")
        var xmlRequest = URLRequest(url: path!)
        xmlRequest.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        let dataTask = session.dataTask(with: xmlRequest){(responseData,response,error) in
            if responseData != nil{
                print(responseData!)
                print(response!)
                let booksParser: BooksParser = BooksParser()
                booksParser.delegate = self
                booksParser.Parse(data: responseData!)
            }else{
                print("no data available")
            }
        }
        dataTask.resume()
    }
}
