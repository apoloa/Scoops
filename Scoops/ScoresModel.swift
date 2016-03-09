//
//  ScoresModel.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 08/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import Foundation

let keyScoreDictionary = "scoresDictionary"

func saveScoresInDefaults(id:String, score:Double){
    
    var dictionary = loadDictionaryScores()
    dictionary[id] = score
    NSUserDefaults.standardUserDefaults().setObject(dictionary, forKey: keyScoreDictionary)
}

func getScoreInDefaults(id:String) -> Double?{
    var dictionary = loadDictionaryScores()
    return dictionary[id]
}


func loadDictionaryScores() -> [String:Double] {
    if let dictionary = NSUserDefaults.standardUserDefaults().objectForKey(keyUserId) as? [String:Double] {
        return dictionary
    }
    
    return [String:Double]()
}