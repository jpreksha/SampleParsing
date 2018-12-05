//
//  BooksParser.swift
//  SampleParsing
//
//  Created by Preksha Jaiswal on 11/26/18.
//  Copyright © 2018 Infor. All rights reserved.
//

import UIKit

@objc protocol BooksParserDelegate {
  @objc optional func completedParsing()
}
class BooksParser: NSObject,XMLParserDelegate{
  
//    <book id="bk101">
//    <author>Gambardella, Matthew</author>
//    <title>XML Developer's Guide</title>
//    <genre>Computer</genre>
//    <price>44.95</price>
//    <publish_date>2000-10-01</publish_date>
//    <description>An in-depth look at creating applications
//    with XML.</description>
//    </book>
    var delegate: BooksParserDelegate?
    var ename: String = String()
    var catalog:BookCatalog = BookCatalog()
    var books: Book = Book()
    var catalogs: [BookCatalog] = []
    var booksData: [Book] = []
    static let sharedInstance = BooksParser()
    
    func Parse(data:Data)->Void{
        let parser = XMLParser(data:data)
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        ename = elementName
        if  elementName == "catalog"{
           catalog = BookCatalog()
        }else if elementName == "book"{
            books = Book()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        ename = elementName
        if elementName == "catalog"{
            catalogs.append(catalog)
        }else if elementName == "book"{
            catalog.books.append(books)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if ename == "book id" {
            books.bookID += string
        }else if ename == "author" {
            books.author += string
        }else if ename == "title"{
            books.title += string
        }else if ename == "genre"{
            books.genre += string
        }else if ename == "price"{
            books.price += string
        }else if ename == "description"{
            books.bookDescription += string
        }
    }
}
