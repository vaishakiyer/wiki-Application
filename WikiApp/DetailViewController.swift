//
//  DetailViewController.swift
//  WikiApp
//
//  Created by Vaishak.Iyer on 22/06/18.
//  Copyright © 2018 Vaishak.Iyer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personDesc: UILabel!
    
    var personName : String?
    var setImage : String?
    var setDesc : String?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = personName
        if setImage != nil
        {
        personImage.downloadedFrom(link: setImage!)
        }else
        {
            personImage.image = UIImage(named: "placeholder")
        }
        personDesc.text = setDesc
        // Do any additional setup after loading the view.
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
