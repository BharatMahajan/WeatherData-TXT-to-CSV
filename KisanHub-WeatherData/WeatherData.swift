//
//  WeatherData.swift
//  KisanHub-WeatherData
//
//  Created by Er. Bharat Mahajan on 10/10/17.
//  Copyright © 2017 Er. Bharat Mahajan. All rights reserved.
//
//WeatherData Model to save data in required csv format
import UIKit

class WeatherData: NSObject {
    var region_code : String = ""
    var weather_param : String = ""
    var year : String = ""
    var key : String = ""
    var value : String = ""
    
    init(region_code:String, weather_param:String, year:String, key:String, value:String) {
        self.region_code = region_code;
        self.weather_param = weather_param
        self.year = year
        self.key = key
        self.value = value
    }
}
