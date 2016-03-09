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
            self.imageNews.image = image
        }.addDisposableTo(disposableBag)
    }
}
