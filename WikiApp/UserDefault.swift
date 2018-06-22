//
//  UserDefault.swift
//  WikiApp
//
//  Created by Vaishak.Iyer on 22/06/18.
//  Copyright © 2018 Vaishak.Iyer. All rights reserved.
//

import Foundation

let kWiki = "kWiki"

class UserDefault {
    
    static let sharedInstance = Foundation.UserDefaults.standard
    
    class func fetchAllWikiResult() -> [Wiki]? {
        
        var wikiArray = [Wiki]()
        
        guard let data = Foundation.UserDefaults.standard.object(forKey: kWiki) as? Data else
        {
            return nil
        }
        
        let object = NSKeyedUnarchiver.unarchiveObject(with: data) as! [NSDictionary]
        
        for items in object
        {
            let obj = Wiki(JSON: items)
            wikiArray.append(obj)
        }
       
        return wikiArray
        
    }

    class func setWikiResult(_ userDict: [NSDictionary]) {
        
        sharedInstance.set(NSKeyedArchiver.archivedData(withRootObject: userDict), forKey: kWiki)
        
        sharedInstance.synchronize()
        
    }
    
    
    
}
