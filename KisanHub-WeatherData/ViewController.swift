//
//  ViewController.swift
//  KisanHub-WeatherData
//
//  Created by Er. Bharat Mahajan on 08/10/17.
//  Copyright © 2017 Er. Bharat Mahajan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: Enum for Regions
    enum Regions: String {
        case UK = "UK"
        case England = "England"
        case Wales = "Wales"
        case Scotland = "Scotland"
    }
    //MARK: Enum for Weather Parameters
    enum WeatherParams : String{
        case MaxTemp = "Tmax"
        case MinTemp = "Tmin"
        case MeanTemp = "Tmean"
        case Sunshine = "Sunshine"
        case Rainfall = "Rainfall"
    }
    
    //MARK: IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! //activity Indicator
    @IBOutlet weak var btnParse: UIButton! //Parse button
    @IBOutlet weak var btnShare: UIButton! //Share button
    
    //MARK: Variables
    var regionValue = "" //Region Values
    var weatherParamValue  = "" //Weather Parameter Values
    var arrWeatherData = [WeatherData]() //Array to save mulitple values of base WeatherParameter Model
    var isMultiple = false
    var downloadedItems = 0
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isMultiple = false
        regionValue = Regions.UK.rawValue
        weatherParamValue = WeatherParams.MinTemp.rawValue
        activityIndicator.stopAnimating()
        
        //Check if csv file exists to show share button
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("WeatherData.csv")
        let filePresentPath   : String    = dataPath.path
        let fileManager : FileManager   = FileManager.default
        if fileManager.fileExists(atPath:filePresentPath){
            btnShare.isHidden = false
        }
        else{
            btnShare.isHidden = true
        }
    }
    
    //MARK: parse data to csv
    @IBAction func parseData(_ sender: UIButton) {
        activityIndicator.isHidden = false;
        activityIndicator.startAnimating()
        
        let arrRegions = [Regions.UK.rawValue,Regions.England.rawValue,Regions.Wales.rawValue,Regions.Scotland.rawValue]
        for(_,items) in arrRegions.enumerated(){
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dataPath = documentsDirectory.appendingPathComponent(items)
            let filemanager:FileManager = FileManager()
            let files = filemanager.enumerator(atPath: dataPath.relativePath)
            
            while let file = files?.nextObject() {
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let dicURL = dir.appendingPathComponent(items)
                    let fileURL = dicURL.appendingPathComponent(file as! String)
                    let fileType = (fileURL.absoluteString as NSString).lastPathComponent
                    //discard .DS_Store files
                    if fileType == ".DS_Store"
                    {
                        continue
                    }
                    
                    let filePresentPath   : String    = fileURL.path
                    let fileManager : FileManager   = FileManager.default
                    
                    if fileManager.fileExists(atPath:filePresentPath)
                    {
                        let weatherParamOfFile = (fileURL.absoluteString as NSString).lastPathComponent.components(separatedBy: ".").first
                        
                        if weatherParamOfFile==WeatherParams.MinTemp.rawValue
                        {
                            weatherParamValue = "Min Temp"
                        }
                        else if weatherParamOfFile==WeatherParams.MaxTemp.rawValue
                        {
                            weatherParamValue = "Max Temp"
                        }
                        else if weatherParamOfFile==WeatherParams.MeanTemp.rawValue
                        {
                            weatherParamValue = "Mean Temp"
                        }
                        else if weatherParamOfFile==WeatherParams.Sunshine.rawValue
                        {
                            weatherParamValue = "Sunshine"
                        }
                        else if weatherParamOfFile==WeatherParams.Rainfall.rawValue
                        {
                            weatherParamValue = "Rainfall"
                        }
                        
                        //reading txt file
                        let text2 = try? String(contentsOf: fileURL, encoding: .utf8)
                        //break txt file line by line
                        var myStrings = text2?.components(separatedBy: "\r\n")
                        //create guideline top bar i.e. YEAR,JAN,FEB...
                        var guideBar = [String]()
                        
                        //remove top rows which doesn't consist of tabular data
                        for(index,stringElement) in (myStrings?.enumerated())!{
                            let firstWord = stringElement.components(separatedBy: " ").first
                            if firstWord == "Year"
                            {
                                guideBar = self.createWordsFromLines(inputLine: stringElement)
                                myStrings?.removeFirst(index)
                                break
                            }
                        }
                        myStrings?.removeFirst()
                        
                        //created model to save data as per requirement of csv
                        for (_,element) in (myStrings?.enumerated())!{
                            var arrwords = self.createWordsFromLines(inputLine: element)
                            for (newindex,newelement) in (arrwords.enumerated()){
                                var newWeatherData : WeatherData
                                newWeatherData = WeatherData.init(region_code: items, weather_param: weatherParamValue, year: arrwords[0], key: guideBar[newindex], value: newelement)
                                arrWeatherData.insert(newWeatherData, at: arrWeatherData.count)
                            }
                        }
                    }
                }
            }
        }
        
        //Create csv
        let fileName = "WeatherData.csv"
        var csvText = "Weather Data\nregion_code,weather_param,year, key, value\n"
        
        for (_,elements) in arrWeatherData.enumerated()
        {
            if elements.key == "Year"
            {
                continue
            }
            let newLine = "\(elements.region_code),\(elements.weather_param),\(elements.year),\(elements.key),\(elements.value)\n"
            csvText.append(newLine)
        }
        
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dataPath = documentsDirectory.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: dataPath)
            
            try csvText.write(to: dataPath, atomically: true, encoding: String.Encoding.utf8)
            self.activityIndicator.stopAnimating()
            btnShare.isHidden = false
        } catch {
            self.activityIndicator.stopAnimating()
            
            let alert = UIAlertController(title: "Failed to create csv file" , message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: share csv File
    @IBAction func sharecsvFile(_ sender: UIButton) {
        let fileName = "WeatherData.csv"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent(fileName)
        
        
        let vc = UIActivityViewController(activityItems: [dataPath], applicationActivities: [])
        vc.excludedActivityTypes = [
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo,
            UIActivityType.postToTwitter,
            UIActivityType.postToFacebook,
            UIActivityType.openInIBooks
        ]
        present(vc, animated: true, completion: nil)
        
        
    }
    //MARK: fetch value for segments (Region or Weather Parameters)
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.tag {
        case 0:
            regionValue = sender.titleForSegment(at: sender.selectedSegmentIndex)!
            break
        case 1:
            
            switch sender.selectedSegmentIndex{
            case 0:
                weatherParamValue = WeatherParams.MinTemp.rawValue
                break
            case 1:
                weatherParamValue = WeatherParams.MaxTemp.rawValue
                break
            case 2:
                weatherParamValue = WeatherParams.MeanTemp.rawValue
                break
            case 3:
                weatherParamValue = WeatherParams.Sunshine.rawValue
                break
            case 4:
                weatherParamValue = WeatherParams.Rainfall.rawValue
                break
            default:
                break
            }
            
            break
        default:
            break
            
        }
    }

    //MARK: Download all data
    @IBAction func downloadAllData(_ sender: UIButton) {
        activityIndicator.isHidden = false;
        activityIndicator.startAnimating()
        downloadedItems = 0
        isMultiple = true
        let arrRegions = [Regions.UK.rawValue,Regions.England.rawValue,Regions.Wales.rawValue,Regions.Scotland.rawValue]
        for(_,itemsRegion) in arrRegions.enumerated(){
            let arrWeatherParams = [WeatherParams.MinTemp.rawValue,WeatherParams.MaxTemp.rawValue,WeatherParams.MeanTemp.rawValue,WeatherParams.Sunshine.rawValue,WeatherParams.Rainfall.rawValue]
            for(_,itemsWeather) in arrWeatherParams.enumerated(){
                var urlString : String
                urlString = kDownloadURL+itemsWeather+"/date/"+itemsRegion+".txt"
                let URLString = NSURL(string: urlString)
                self.load(URL: URLString!, region: itemsRegion, weatherParam: itemsWeather)
            }
        }
    }
    
    //MARK: Download data based on selected segment
    @IBAction func downloadData(_ sender: UIButton) {
        isMultiple = false
        activityIndicator.isHidden = false;
        activityIndicator.startAnimating()
        var urlString : String
        urlString = kDownloadURL+weatherParamValue+"/date/"+regionValue+".txt"
        let URLString = NSURL(string: urlString)
        self.load(URL: URLString!, region: regionValue, weatherParam: weatherParamValue)
    }
    
    //MARK: Segregate individual data from each line of text file
    func createWordsFromLines(inputLine: String ) -> [String] {
        
        var arrString = inputLine.components(separatedBy: .whitespaces)
        arrString = arrString.filter { $0 != "" }
        
        if arrString.first != "Year"
        {
            for (index,element) in arrString.enumerated() {
                let myFloat = (element as NSString).floatValue
                if myFloat == 0.0 && arrString.count > 13
                {
                    arrString.remove(at: index)
                    arrString.insert("N/A", at: index)
                }
                if arrString.count<18
                {
                    arrString.insert("N/A", at: 10)
                    arrString.insert("N/A", at: 11)
                    arrString.insert("N/A", at: 12)
                    arrString.append("N/A")
                    arrString.append("N/A")
                }
            }
        }
        return arrString
    }
    
    //MARK: download data for selected region and weather parameters
    func load(URL: NSURL, region:String, weatherParam:String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent(region)
        print("Folder Path : ",dataPath)
        try? FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        
        var fileName : String
        fileName = weatherParam
        fileName+=".txt"
        
        let destinationFileUrl = dataPath.appendingPathComponent(fileName)
        
        let filePresentPath   : String    = destinationFileUrl.path
        let fileManager : FileManager   = FileManager.default
        
        if fileManager.fileExists(atPath:filePresentPath){
            
            if !isMultiple
            {
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "File already downloaded!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else
            {
                downloadedItems = downloadedItems+1
                if downloadedItems == 20
                {
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: "All Files Downloaded", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
        }
        
        //Create URL to the source file you want to download
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:URL as URL)
        
        DispatchQueue.global(qos: .background).async {
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if ((response as? HTTPURLResponse)?.statusCode) != nil {
                        DispatchQueue.main.async {
                            if !self.isMultiple
                            {
                            self.activityIndicator.stopAnimating()
                            
                            let alert = UIAlertController(title: "Successfully downloaded", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            }
                            else
                            {
                                self.downloadedItems = self.downloadedItems+1
                                if self.downloadedItems == 20
                                {
                                    self.activityIndicator.stopAnimating()
                                    let alert = UIAlertController(title: "All Files Downloaded", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    return
                                }
                            }
                        }
                    }
                    
                    
                    try? FileManager.default.removeItem(at: destinationFileUrl)
                    try? FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } else {
                    DispatchQueue.main.async {
                        if !self.isMultiple
                        {
                        self.activityIndicator.stopAnimating()
                        let alert = UIAlertController(title: "Not able to download due to "+(error?.localizedDescription)! , message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                        else
                        {
                            self.downloadedItems = self.downloadedItems+1
                            if self.downloadedItems == 20
                            {
                                self.activityIndicator.stopAnimating()
                                let alert = UIAlertController(title: "All Files Downloaded", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



