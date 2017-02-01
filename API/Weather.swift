//
//  Weather.swift
//  SwiftOpenWeatherMapAPI
//
//  Created by Filippo Tosetto on 10/11/2015.
//
//

import SwiftyJSON

struct Weather {
    var dateTime: String
    var description: String
    var temperature: String
    var location: String
    
    init(json: JSON) {
        self.dateTime = json["dt"].doubleValue.convertTimeToString()
        self.description = json["weather"][0]["description"].stringValue
        self.temperature = String(json["main"]["temp"].intValue)
        self.location = String(json["name"].stringValue)
    }
}
