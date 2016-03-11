//
//  NewsTableViewCell.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 07/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NewsTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var titleNews: UILabel!
    @IBOutlet weak var imageNews: UIImageView!
    
    // MARK: Variables
    private let disposableBag = DisposeBag()
    
    // MARK: RxBindings
    func binding(title: String, imageObservable:Observable<UIImage>){
        titleNews.text = title;
        imageObservable.bindNext { (image : UIImage) -> Void in
            let gradient = CAGradientLayer()
            gradient.frame = self.imageNews.frame
            gradient.colors = [UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.4).CGColor, UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0).CGColor]
            
            self.imageNews.layer.insertSublayer(gradient, atIndex: 0)
            self.imageNews.image = image
            
        }.addDisposableTo(disposableBag)
    }
}
