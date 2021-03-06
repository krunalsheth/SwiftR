//
//  ViewController.swift
//  SwiftR Mac Demo
//
//  Created by Adam Hartford on 4/16/15.
//  Copyright (c) 2015 Adam Hartford. All rights reserved.
//

import Cocoa
import SwiftR

class ViewController: NSViewController {
    
    var simpleHub: Hub!
    var complexHub: Hub!
    
    var persistentConnection: SignalR!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure myserver.com is mapped to 127.0.0.1 /etc/hosts
        // Or change myserver.com to localhost below
        
        // Hubs...
        SwiftR.connect("http://myserver.com:8080") { [weak self] connection in
            connection.queryString = ["foo": "bar"]
            connection.setValue("Value1", forHTTPHeaderField: "X-MyHeader1")
            connection.setValue("Value2", forHTTPHeaderField: "X-MyHeader2")
            
            self?.simpleHub = connection.createHubProxy("simpleHub")
            self?.complexHub = connection.createHubProxy("complexHub")
            
            self?.simpleHub.on("notifySimple", parameters: ["message", "details"]) { response in
                let message = response!["message"] as! String
                let detail = response!["details"] as! String
                println("Message: \(message)\nDetail: \(detail)\n")
            }
            
            self?.complexHub.on("notifyComplex") { (response) in
                let m: AnyObject = response!["0"] as AnyObject!
                println(m)
            }
        }
        
        // Persistent connection...
        // Uncomment when using persitent connections on your SignalR server
//        persistentConnection = SwiftR.connect("http://myserver.com:8080/echo", connectionType: .Persistent) { connection in
//            connection.received = { (data) in
//                println(data!)
//            }
//        }
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func sendSimpleMessage(sender: AnyObject?) {
        simpleHub.invoke("sendSimple", arguments: ["Simple Test", "This is a simple message"])
    }
    
    @IBAction func sendComplexMessage(sender: AnyObject?) {
        let message = [
            "messageId": 1,
            "message": "Complex Test",
            "detail": "This is a complex message",
            "items": ["foo", "bar", "baz"]
        ]
        
        complexHub.invoke("sendComplex", arguments: [message])
    }

    @IBAction func sendData(sender: AnyObject?) {
        persistentConnection.send("Persistent Connection Test")
    }
    
}

