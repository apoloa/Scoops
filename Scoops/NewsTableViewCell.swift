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
    @IBOutlet weak var titleNews: UILabel!
    @IBOutlet weak var imageNews: UIImageView!
    
    private let disposableBag = DisposeBag()
    
    func binding(title: String, imageObservable:Observable<UIImage>){
        titleNews.text = title;
        imageObservable.bindNext { (image : UIImage) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageNews.image = image
            })
        }.addDisposableTo(disposableBag)
    }
}
