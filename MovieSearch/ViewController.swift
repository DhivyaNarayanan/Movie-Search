//
//  ViewController.swift
//  MovieSearch
//
//  Created by Dhivya Narayanan on 10/20/16.
//  Copyright © 2016 Dhivya Narayanan. All rights reserved.
//

import UIKit

struct MovieData{
    let title: String?
    let id: Int?
    let popularity: Double?
    init(_ title: String, _ id: Int, _ popularity: Double){
        self.title = title
        self.id = id
        self.popularity = popularity
    }
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var movieSearchBar: UISearchBar?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var dropdownView: UIView?
    
    @IBOutlet var titleLabel: UILabel?
  //  @IBOutlet var subtitleLabel: UILabel?
    @IBOutlet var imdbRatingLabel: UILabel?
    @IBOutlet var ratedLabel: UILabel?
    @IBOutlet var plotLabel: UILabel?
    @IBOutlet var releasedDateLabel: UILabel?
    @IBOutlet var posterImageView: UIImageView?
    @IBOutlet var homepageLink: UIButton?
    
   
    @IBAction func openLink(sender: AnyObject) {
        if(self.homepage != nil){
            UIApplication.sharedApplication().openURL(NSURL(string: self.homepage!)!)
        }
    }
    
    

    var TableData: Array<MovieData> = Array<MovieData>()
    
    var curTitle: String?
    var curId: Int?
    var curImdbId: String?
    var posterPath: String?
    var releaseDate: String?
    var rated: String?
    var imdbRating: String?
    var plot: String?
    var curImage: UIImage?
    var homepage: String?
    var genre: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.formatLabels(true)
        if((self.curImage) != nil){
            self.blurBackgroundUsingImage((self.curImage)!, view: tableView!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        self.clearViews()
        
        TableData.removeAll(keepCapacity: false)
        self.searchAPI(searchBar.text!)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return TableData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    let cell:CustomTableViewCell = self.tableView!.dequeueReusableCellWithIdentifier("Cell") as! CustomTableViewCell
        
        cell.cellLabel?.text = TableData[indexPath.row].title
        cell.backgroundColor = UIColor.clearColor()
        cell.cellLabel?.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.curId = TableData[indexPath.row].id
        self.curTitle = TableData[indexPath.row].title
        self.getImdbId(curId!)
        self.movieSearchBar?.text = self.curTitle
        tableView.hidden = true
        
    }
    
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
       let cel:CustomTableViewCell = cell as! CustomTableViewCell
       cel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
    
    }

    //Step1a : Get list of movies and get movie id and title
    func searchAPI(forContent: String){
        
        let url : String = "https://api.themoviedb.org/3/search/movie?api_key=bef32c53cda521a89c23f2adb6541964&query=\(forContent)"
        let urlStr : String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        let searchURL : NSURL = NSURL(string: urlStr)!
        print(searchURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(searchURL){
            data, response, error -> Void in
            if((error) != nil){
                print(error!.localizedDescription)
            }
            var jsonError : NSError?
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            if((jsonError) != nil){
                print(jsonError!.localizedDescription)
            }
            print(jsonResult)
            dispatch_async(dispatch_get_main_queue()){
                self.didFinishSearchAPI(jsonResult)
             }
            
          }
         task.resume()
            
    }
    
    //Step1b. Display movies in the table
    func didFinishSearchAPI(result: NSDictionary){
        
        self.view.sendSubviewToBack(self.posterImageView!)
        self.view.bringSubviewToFront(dropdownView!)
        dropdownView?.hidden = false
        tableView!.hidden = false
        self.dropdownView!.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        self.tableView?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        self.tableView!.tableFooterView = UIView(frame: CGRectZero)
        if let movie_results = result["results"] as? NSArray{
            if (movie_results.count == 0){
                self.movieSearchBar?.text = "Match Not Found!"
                self.dropdownView?.hidden = true
            }
            else{
                for(var i=0; i < movie_results.count ; i++){
                    if let movie_obj = movie_results[i] as? NSDictionary{
                         let movie_title = movie_obj["title"] as? String
                         let movie_id = movie_obj["id"] as? Int
                         let movie_popularity = movie_obj["popularity"] as? Double
                         let data: MovieData = MovieData(movie_title!,movie_id!, movie_popularity!)
                         TableData.append(data)
                    }
                }
            }

        }
        self.TableData.sortInPlace(){(($0 as MovieData).popularity) > (($1 as MovieData).popularity)}
        tableView?.reloadData()
        
    }
    
    //Step2a. Get Imdb id
    func getImdbId(movieId: Int){
        
        let url : String = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=bef32c53cda521a89c23f2adb6541964"
        let urlStr : String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        let searchURL : NSURL = NSURL(string: urlStr)!
        print(searchURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(searchURL){
            data, response, error -> Void in
            if((error) != nil){
                print(error!.localizedDescription)
            }
            var jsonError : NSError?
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            if((jsonError) != nil){
                print(jsonError!.localizedDescription)
            }
            print(jsonResult)
            dispatch_async(dispatch_get_main_queue()){
                self.didFinishGetImdbId(jsonResult)
            }
            
        }
        task.resume()

        
    }
    
    //step2b. Retrieve Id from JSON
    func didFinishGetImdbId(result: NSDictionary){
        
        if let imdbid = result["imdb_id"] as? String{
            self.curImdbId = imdbid
            self.releaseDate = result["release_date"] as? String
            self.homepage = result["homepage"] as? String
            //self.textLabel?.text = self.curImdbId
            
            self.getMovieData(self.curImdbId!)
        }
        else{
            self.imdbRatingLabel?.text = "Movie Details Not Available!!"
            self.dropdownView?.hidden = true
        }
       
        
    }
    
    //Step3a. Get movie Data
    func getMovieData(imdbId: String){
        
        let url : String = "https://www.omdbapi.com/?i=\(imdbId)"
        let urlStr : String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        let searchURL : NSURL = NSURL(string: urlStr)!
        print(searchURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(searchURL){
            data, response, error -> Void in
            if((error) != nil){
                print(error!.localizedDescription)
            }
            var jsonError : NSError?
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            if((jsonError) != nil){
                print(jsonError!.localizedDescription)
            }
            print(jsonResult)
            dispatch_async(dispatch_get_main_queue()){
                self.didFinishGetMovieData(jsonResult)
            }
            
        }
        task.resume()
    }
    
    //Step3b. Display movieDetails
    func didFinishGetMovieData(result: NSDictionary){
        
        
        self.view.bringSubviewToFront(self.posterImageView!)
        self.view.sendSubviewToBack(self.dropdownView!)

        self.posterImageView?.hidden = false
        self.formatLabels(false)
        if let foundPoster = result["Poster"] as? String{
            if(foundPoster != "N/A"){
                self.posterPath = foundPoster
                self.formatImageFromPath(posterPath!)
            }else{
                self.posterImageView?.image = UIImage(named: "notavailable.jpg")
                self.posterImageView?.layer.cornerRadius = 80.0
                self.posterImageView?.clipsToBounds = true
                self.curImage = self.posterImageView?.image
                self.blurBackgroundUsingImage((self.posterImageView?.image)!, view: self.view)
            }
        }else{
            
            self.posterImageView?.image = UIImage(named: "notavailable.jpg")
            self.posterImageView?.layer.cornerRadius = 80.0
            self.posterImageView?.clipsToBounds = true
            self.curImage = self.posterImageView?.image
            self.blurBackgroundUsingImage((self.posterImageView?.image)!, view: self.view)
        }
       
        self.titleLabel?.text = self.curTitle
        self.releasedDateLabel?.text = "Released on: " + self.releaseDate!
        if let foundRated = result["Rated"] as? String{
            self.rated = foundRated
           // self.ratedLabel?.text = "Rated: " + self.rated!
        }
        if let foundRating = result["imdbRating"] as? String{
             self.imdbRating = foundRating
             self.imdbRatingLabel?.text = self.imdbRating
        }
        
        if let foundPlot = result["Plot"] as? String{
             self.plot = foundPlot
            self.plotLabel?.text = self.plot

        }
        if let foundGenre = result["Genre"] as? String{
            self.genre = foundGenre
            self.ratedLabel?.text = "Genre: " + self.genre!
        }
        if(self.homepage != nil){
           // self.homepageLink?.text = self.homepage
            self.homepageLink?.setTitle(self.homepage, forState: UIControlState.Normal)
            self.homepageLink?.setTitleColor(UIColor.blueColor().colorWithAlphaComponent(0.6), forState: UIControlState.Normal)
        }
    }
    
    /*func parseTitle(title: String){
        let index = title.findIndexOf(":")
        if let foundIndex = index {
            
            let newTitle = title[0..<foundIndex]
         //   let subTitle = title[foundIndex + 2..<title.characters.count]
            
            self.titleLabel?.text = newTitle
          //  self.subtitleLabel?.text = subTitle
            
        } else{
            self.titleLabel?.text = title
          //  self.subtitleLabel?.text = ""
        }
        
    }
    */
    
    func formatLabels(firstLaunch : Bool){
        
        let labelsArrray = [self.titleLabel, self.plotLabel, self.releasedDateLabel, self.ratedLabel, self.imdbRatingLabel]
        
        if(firstLaunch){
            for label in labelsArrray{
                label?.text=""
            }
            self.homepageLink?.setTitle("", forState: UIControlState.Normal)
            self.tableView?.hidden = true
            self.dropdownView?.hidden = true
            self.view.backgroundColor = UIColor(red: 0.9373, green: 0.8627, blue: 0.9569, alpha: 1.0)
        }
        
        for label in labelsArrray{
            label?.textAlignment = .Center
            if let curLabel = label{
                switch curLabel{
                case self.titleLabel!:
                    curLabel.font = UIFont(name: "Avenir Next", size: 24)
                    break
                case self.imdbRatingLabel!:
                    curLabel.font = UIFont(name: "Avenir Next", size: 38)
                    curLabel.textColor = UIColor(red: 0.984, green: 0.259, blue: 0.184, alpha: 1)
                    break
                case self.ratedLabel!, self.releasedDateLabel!:
                    curLabel.font = UIFont(name:"Avenir Next", size:16)
                    break
                case self.plotLabel!:
                    curLabel.font = UIFont(name: "Avenir Next", size: 16)
                    break
                default:
                    curLabel.font = UIFont(name: "Avenir Next", size: 14)
                    break
                }
            }
        }
        
    }

    
    func formatImageFromPath(path: String){
        
        let posterUrl = NSURL(string: path)
        let posterImageData = NSData(contentsOfURL: posterUrl!)
        self.posterImageView?.layer.cornerRadius = 80.0
        self.posterImageView?.clipsToBounds = true
        self.posterImageView?.image = UIImage(data: posterImageData!)
        
        self.curImage = self.posterImageView?.image
        
        self.blurBackgroundUsingImage((self.posterImageView?.image)!, view: self.view)
        
    }
    
    
    func blurBackgroundUsingImage(image: UIImage, view: UIView){
        
        let frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        
        let transparentWhiteView = UIView(frame: frame)
        transparentWhiteView.backgroundColor = UIColor(white: 1.0, alpha: 0.30)
        
        var viewsArray = [imageView,blurEffectView,transparentWhiteView]
        
        for index in 0..<viewsArray.count{
            if let _ = self.view.viewWithTag(index+1){
                let oldView = self.view.viewWithTag(index+1)
                oldView?.removeFromSuperview()
            }
            
            let viewToInsert = viewsArray[index]
            self.view.insertSubview(viewToInsert, atIndex: index+1 )
            viewToInsert.tag = index + 1
        }
        
    }
    
    

    func clearViews(){
        self.titleLabel?.text=""
        self.plotLabel?.text=""
        self.releasedDateLabel?.text=""
        self.imdbRatingLabel?.text=""
        self.ratedLabel?.text=""
        self.posterImageView?.hidden = true
    }

    

}

extension MovieData: Equatable{}

func == (lhs: MovieData, rhs: MovieData) -> Bool {
    return lhs.title == rhs.title && lhs.id == rhs.id && lhs.popularity == rhs.popularity
}
