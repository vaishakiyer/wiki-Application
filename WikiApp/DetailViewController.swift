//
//  DetailViewController.swift
//  WikiApp
//
//  Created by Vaishak.Iyer on 22/06/18.
//  Copyright © 2018 Vaishak.Iyer. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController{
    
 
    @IBOutlet weak var webKitRederer: WKWebView!
    
    var personName : String?
   

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.title = personName
        renderWebPage()
        // Do any additional setup after loading the view.
    }
    
    
    func renderWebPage()
    {
        personName = personName?.replacingOccurrences(of: " ", with: "_")
        
        let BaseString = "https://en.wikipedia.org/wiki/\(personName!)"
        if let urlToLoad = URL(string: BaseString)
        {
            let urlRequest = URLRequest(url: urlToLoad, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            webKitRederer.load(urlRequest)
        }
        
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
