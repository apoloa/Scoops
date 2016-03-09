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
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        newsTitle.rx_text.asObservable().bindNext { (value) -> Void in
            self.title = value
        }
        .addDisposableTo(disposeBag)
    
    }
    
    // MARK: - Navigations Selectors
    
    func save(sender: AnyObject){
        
        let currentLocation = LocationManager.sharedInstance.currentLocation
        
        var latitude : Double = 0
        var longitude : Double = 0
        
        if let location = currentLocation {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        if let image = image {
            let model = News(title: newsTitle.text!, text: newsBody.text!, latitude: latitude, longitude: longitude, image:image, status: StatusNews.Draft)
            model.uploadToAzure()

        }
    
        
        navigationController?.popViewControllerAnimated(true)
        
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
}




