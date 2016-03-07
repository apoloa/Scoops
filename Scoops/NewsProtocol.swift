//
//  NewsProtocol.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 07/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import Foundation

protocol NewsViewModelType: class{
    
    var numberOfSections: Int { get }
    
    subscript(section: Int) -> String { get }
    
    subscript(section: Int) -> Int { get }
    
    subscript(section sect: Int , row: Int) -> News { get }
    
    func populateNews(completion: CompletionBlock)
    
}