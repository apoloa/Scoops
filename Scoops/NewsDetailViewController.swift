//
//  DetailViewController.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 28/02/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewsDetailViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var imageNews: UIImageView!
    @IBOutlet weak var titleNews: UILabel!
    @IBOutlet var puntuation: [UIImageView]!
    @IBOutlet weak var textNews: UITextView!
    @IBOutlet weak var authorNews: UILabel!
    
    @IBOutlet var starTap: UITapGestureRecognizer!
    @IBOutlet weak var stackPuntuation: UIStackView!
    
    // MARK: Variables
    
    private let disposeBag = DisposeBag()
    
    var news: News? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    
    // MARK: Configure View
    
    func configureView() {
        // Update the user interface for the detail item.
        if let news = self.news {
            if let imageNews = imageNews{
                news.getImageFromAzure().bindNext({ (image) -> Void in
                    let gradient = CAGradientLayer()
                    gradient.frame = imageNews.frame
                    gradient.colors = [UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.4).CGColor, UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0).CGColor]
                    imageNews.layer.insertSublayer(gradient, atIndex: 0)
                    imageNews.image = image
                }).addDisposableTo(disposeBag)
            }
            if let titleNews = titleNews{
                titleNews.text = news.title
                self.title = news.title
            }
            if let authorNews = authorNews,
                let name = news.author{
                    authorNews.text = name
            }
            if let textNews = textNews{
                textNews.text = news.text
                switch news.status{
                case .Published:
                    textNews.editable = false
                    stackPuntuation.hidden = false
                    if news.total_likes != 0 {
                        drawStars(news.score/news.total_likes)
                    }else{
                        drawStars(0)
                    }
                    break
                case .Publish:
                    textNews.editable = false
                    stackPuntuation.hidden = true
                    break
                case .Draft:
                    textNews.editable = true
                    stackPuntuation.hidden = true
                    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "")
                    break
                }
            }
            
        }
    }
    
    // MARK: - Stars Score
    func drawStars(score:Double){
        switch score {
        case 0...0.25:
            setStars(0, midStar: false)
            break
        case 0.25...0.75:
            setStars(1, midStar: true)
            break
        case 0.76...1.25:
            setStars(1, midStar: false)
            break
        case 1.25...1.75:
            setStars(2, midStar: true)
            break
        case 1.75...2.25:
            setStars(2, midStar: false)
            break
        case 2.25...2.75:
            setStars(3, midStar: true)
            break
        case 2.75...3.25:
            setStars(3, midStar: false)
            break
        case 3.25...3.75:
            setStars(4, midStar: true)
            break
        case 3.75...4.25:
            setStars(4, midStar: false)
            break
        case 4.25...4.75:
            setStars(4, midStar: true)
            break
        case 4.75...5:
            setStars(5, midStar: false)
            break
        default:
            break
        }
    }
    
    func setStars(position:Int, midStar:Bool){
        let completeStar = UIImage(named: "star_complete.png")
        let semiStar = UIImage(named: "star_semi.png")
        let emptyStar = UIImage(named: "star_empty.png")
        if position == 0 {
            for i in 0...4{
                puntuation[i].image = emptyStar
            }
        }else{
            for i in 0...position-1{
                if midStar  && i == position-1 {
                    puntuation[i].image = semiStar
                } else {
                    puntuation[i].image = completeStar
                }
            }
            if position < 5{
                for j in (position)...4{
                    puntuation[j].image = emptyStar
                }
            }
            
        }
        
    }
    
    func setColorToStars(){
        for i in puntuation{
            i.image = i.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            i.tintColor = UIColor.blueColor()
        }
    }
    
    // MARK: Override Methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    // MARK: IBActions
    
    @IBAction func handleStars(sender: AnyObject) {
        self.starTap.enabled = false
        if let tapGesture = sender as? UITapGestureRecognizer{
            let position = Float(tapGesture.locationInView(stackPuntuation).x)
            let rect = stackPuntuation.bounds
            let starWidth : Float = Float(rect.width)/5
            let value = Double(position/starWidth)
            news?.setPuntuation(value, completionBlock: { (error: NSError?) -> Void in
                if error != nil {
                    print("ERROR setting puntuation \(error)")
                    self.starTap.enabled = true
                }else{
                    saveScoresInDefaults((self.news?.id)!, score: value)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.drawStars(value)
                        self.setColorToStars()
                    })
                }
            })
        }
    }
    
}

