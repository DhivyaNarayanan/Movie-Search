//
//  StringExtension.swift
//  MovieSearch
//
//  Created by Dhivya Narayanan on 10/20/16.
//  Copyright © 2016 Dhivya Narayanan. All rights reserved.
//


import Foundation

extension String{
    
    subscript(r: Range<Int>) -> String?{
        
        if !self.isEmpty {
            
            let start = self.startIndex.advancedBy(r.startIndex)
            let end = self.startIndex.advancedBy(r.endIndex)
            
            return substringWithRange(Range(start: start, end: end))
        }
        
        return nil
    }
    
    func findIndexOf(letter: String) -> Int? {
        
        let tempString = self
        var selfArray: [String] = []
        var index = 0
        
        for character in tempString.characters{
            selfArray.append(String(character))
        }
        
        for _ in 0..<selfArray.count{
            if letter == selfArray[index]{
                return index
            }
            ++index
        }
        
        return nil
    }
    
}

