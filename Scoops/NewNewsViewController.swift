//
//  NewNews.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 03/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit

class NewNewsViewController: UIViewController {
    
    @IBOutlet weak var newsTitle: UITextField!
    @IBOutlet weak var newsBody: UITextView!
    @IBOutlet weak var newsImage: UIImageView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save:")
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func save(sender: AnyObject){
        
    }
    
    func cancel(sender: AnyObject){
        
    }
}
