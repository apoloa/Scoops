//
//  NewNews.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 03/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class NewNewsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var newsTitle: UITextField!
    @IBOutlet weak var newsBody: UITextView!
    @IBOutlet weak var newsImage: UIImageView!
    
    // MARK: - Variables
    private let disposeBag = DisposeBag()
    private var image: UIImage?{
        didSet{
            newsImage.image = image
        }
    }
    
    // MARK: - SuperClass Methods

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save:")
        saveButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        cancelButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = cancelButton
        
        newsTitle.rx_text.asObservable().bindNext { (value) -> Void in
            self.title = value
        }
        .addDisposableTo(disposeBag)
    
    }
    
    // MARK: - Navigations Selectors
    
    func save(sender: AnyObject){
        openAlertToSelectDraftOrPublish()
    }
    
    func cancel(sender: AnyObject){
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - IBActions
    
    @IBAction func addImage(sender: AnyObject) {
        openAlertToSelectMeansForPhoto()
    }
    
    // MARK: - Alert
    
    func openAlertToSelectMeansForPhoto(){
        let alert = UIAlertController(title: "Do you want to...?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            self.launchImagePicker(UIImagePickerControllerSourceType.Camera)
        }
        
        let selectPhotoLibraryAction = UIAlertAction(title: "Select from library", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            self.launchImagePicker(UIImagePickerControllerSourceType.PhotoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action: UIAlertAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(takePhotoAction)
        alert.addAction(selectPhotoLibraryAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func openAlertToSelectDraftOrPublish(){
        let alert = UIAlertController(title: "Do you want to...?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let publishAction = UIAlertAction(title: "Publish", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            self.saveNews(.Publish)
        }
        
        let draftAction = UIAlertAction(title: "Draft", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            self.saveNews(.Draft)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action: UIAlertAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(publishAction)
        alert.addAction(draftAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }

    
    func launchImagePicker(sourceType: UIImagePickerControllerSourceType){
        let picker =  UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self;
        picker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        self.presentViewController(picker, animated: true) { () -> Void in
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        if let imageOriginal = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = imageOriginal
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: - Functions
    
    func saveNews(status:StatusNews){
        let currentLocation = LocationManager.sharedInstance.currentLocation
        
        var latitude : Double = 0
        var longitude : Double = 0
        
        if let location = currentLocation {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }

        var alertError: UIAlertController? = nil
        print("Text:\(newsTitle.text) - \(newsBody.text)")
        if newsTitle.text == nil || newsTitle.text!.isEmpty {
            alertError = UIAlertController(title: "Error", message:
                "Title News is necessary!", preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        if newsBody.text.isEmpty {
            alertError = UIAlertController(title: "Error", message:
                "Body News is necessary!", preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        if image == nil {
            alertError = UIAlertController(title: "Error", message:
                "Image is necessary!", preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        if let alert = alertError{
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            if let image = image {
                let model = News(title: newsTitle.text!, text: newsBody.text!, latitude: latitude, longitude: longitude, image:image, status: status)
                let activityViewController = ActivityViewController(message: "Uploading...")
                model.uploadToAzure({ (error:NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        activityViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                            if error != nil {
                                let alertController = UIAlertController(title: "Error uploading to Azure", message:
                                    error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }else{
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        })
                    })
                })
                presentViewController(activityViewController, animated: true, completion: nil)
        }
        
        
        
            
        }
    }
}




