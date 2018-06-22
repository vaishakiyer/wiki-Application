//
//  ViewController.swift
//  WikiApp
//
//  Created by Vaishak.Iyer on 22/06/18.
//  Copyright © 2018 Vaishak.Iyer. All rights reserved.
//

import UIKit

struct Wiki {
    
    var titleLabel : String?
    var image : String?
    var descriptionLabel : String? = ""
    
    init(JSON : AnyObject) {
        
        titleLabel =  JSON.value(forKey: "title") as? String
        
        if let imageUrl = JSON.value(forKey: "thumbnail") as? NSDictionary
        {
            
            image = imageUrl.value(forKey: "source") as? String
            
        }
        
        if let descValue = JSON.value(forKey: "terms") as? NSDictionary
        {
         let descriptionArray = descValue.value(forKey: "description") as? [String]
            
            descriptionLabel = descriptionArray?.first
        }
        
    }
    
}

let XScale = UIScreen.main.bounds.size.width / 320.0
let YScale = UIScreen.main.bounds.size.height / 568.0

class ViewController: UIViewController {
    
    @IBOutlet weak var wikiTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: Declare Variables
    
    var wikiObject : [Wiki]? = []
    var filterArray : [Wiki]?
    var searchActive : Bool? = false
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNav()
        searchBar.delegate = self
        wikiTableView.delegate = self
        wikiTableView.dataSource = self
        wikiTableView.separatorStyle = .none
        wikiTableView.register(UITableViewCell.self, forCellReuseIdentifier: "wikiCell")
        
        fetchWikiResponse()
        if let value = UserDefault.fetchAllWikiResult()
        {
            wikiObject = value
            wikiTableView.reloadData()
        }
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    func createNav()
    {
        searchBar.placeholder = "I want to learn about.."
        self.navigationItem.title = "Wikipedia"
    }
    
    func loaderStart()
    {
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = CGPoint(x: (320 * XScale)/2, y: (568 * YScale)/2)
        indicator.bounds = UIScreen.main.bounds
        UIApplication.shared.keyWindow!.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        indicator.startAnimating()
    }
    
    func loaderStop()
    {
        indicator.stopAnimating()
    }
    
    
    //MARK: Network Operation
    
    func fetchWikiResponse()
    {
        loaderStart()
        
        let urlToLoad = "https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=Sachin+T&gpslimit=10"
        
        let request = URLRequest(url: URL(string: urlToLoad)!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (responseData, response, error) in
            
            guard let data = responseData else
            {
                
                DispatchQueue.main.async {
                    self.loaderStop()
                    self.wikiTableView.reloadData()
                    
                }
                print("user is offline")
                return
            }
            
            guard let JSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else
            {
                print("unable to get response")
                return
            }
            print(JSON!)
            
            self.wikiObject?.removeAll()
            
            if let query = JSON?.value(forKey: "query") as? NSDictionary{
               
                if let pages =  query.value(forKey: "pages") as? [NSDictionary] {
               
                UserDefault.setWikiResult(pages)
                    
                for items in pages
                {
                    let singleEntry = Wiki(JSON: items)
                    self.wikiObject?.append(singleEntry)
                }
                    
                }
                
            }
            
            DispatchQueue.main.async {
                self.wikiTableView.reloadData()
                self.loaderStop()
            }
            

        }
        
        task.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension ViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchActive == true {
          return (filterArray?.count)!
        }else
        {
          return (wikiObject?.count)!
        }
            
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
     {
        return 10
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = wikiTableView.dequeueReusableCell(withIdentifier: "wikiCell")
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "wikiCell")
        
        cell?.accessoryType = .disclosureIndicator
        cell?.imageView?.image = UIImage(named: "placeholder")
        cell?.detailTextLabel?.numberOfLines = 0
        
        if searchActive == false
        {
        if let imageString = wikiObject![indexPath.section].image
        {
            cell?.imageView?.downloadedFrom(link: imageString)
        }
        cell?.textLabel?.text = wikiObject![indexPath.section].titleLabel
        cell?.detailTextLabel?.text = wikiObject![indexPath.section].descriptionLabel
        }else
        {
            if let imageString = filterArray![indexPath.section].image
            {
                cell?.imageView?.downloadedFrom(link: imageString)
            }
            cell?.textLabel?.text = filterArray![indexPath.section].titleLabel
            cell?.detailTextLabel?.text = filterArray![indexPath.section].descriptionLabel
            
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let detailController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        
        if searchActive == false
        {
            if let imageString = wikiObject![indexPath.section].image
            {
                detailController?.setImage = imageString
            }
            
            detailController?.personName = wikiObject![indexPath.section].titleLabel
            detailController?.setDesc = wikiObject![indexPath.section].descriptionLabel
        }else
        {
            if let imageString = filterArray![indexPath.section].image
            {
                detailController?.setImage = imageString
            }
            
            detailController?.personName = filterArray![indexPath.section].titleLabel
            detailController?.setDesc = filterArray![indexPath.section].descriptionLabel
            
        }
        
      
        
    
        self.navigationController?.pushViewController(detailController!, animated: true)
        
    }
    
    
}


extension ViewController : UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        searchBar.showsCancelButton = true        
        
    }
    
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
     {
        
        filterArray = wikiObject?.filter({(value) -> Bool in
            
            return ((value.titleLabel?.lowercased().contains(searchText.lowercased()))! || (value.descriptionLabel?.lowercased().contains(searchText.lowercased()))!)
        })
        
         if searchText == ""
         {
            searchActive = false
         }else
         {
            searchActive = true
         }
        
        wikiTableView.reloadData()
        
    }
    
     func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
     {
        searchBar.text = ""
        searchActive = false
        wikiTableView.reloadData()
        self.searchBar.endEditing(true)
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
        
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit)  {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

