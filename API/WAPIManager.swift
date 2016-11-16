//
//  WAPIManager.swift
//  YetAnotherWeatherApp
//
//  Created by Filippo Tosetto on 11/04/2015.
//

import Foundation
import MapKit
import Alamofire
import SwiftyJSON


public enum TemperatureFormat: String {
    case Celsius = "metric"
    case Fahrenheit = "imperial"
    case Kelvin = ""
}

public enum Language : String {
    case English = "en",
    Russian = "ru",
    Italian = "it",
    Spanish = "es",
    Ukrainian = "uk",
    German = "de",
    Portuguese = "pt",
    Romanian = "ro",
    Polish = "pl",
    Finnish = "fi",
    Dutch = "nl",
    French = "fr",
    Bulgarian = "bg",
    Swedish = "sv",
    ChineseTraditional = "zh_tw",
    ChineseSimplified = "zh_cn",
    Turkish = "tr",
    Croatian = "hr",
    Catalan = "ca"
}

public enum WeatherResult {
    case Success(JSON)
    case Error(String)
    
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Error:
            return false
        }
    }
}


public class WAPIManager {
    
    internal var params = [String : Any]()
    public var temperatureFormat: TemperatureFormat = .Kelvin {
        didSet {
            params["units"] = temperatureFormat.rawValue
        }
    }
    
    public var language: Language = .English {
        didSet {
            params["lang"] = language.rawValue
        }
    }
    
    public init(apiKey: String) {
        params["APPID"] = apiKey
    }
    
    public convenience init(apiKey: String, temperatureFormat: TemperatureFormat) {
        self.init(apiKey: apiKey)
        self.temperatureFormat = temperatureFormat
        self.params["units"] = temperatureFormat.rawValue
    }
    
    public convenience init(apiKey: String, temperatureFormat: TemperatureFormat, lang: Language) {
        self.init(apiKey: apiKey, temperatureFormat: temperatureFormat)
        
        self.language = lang
        self.temperatureFormat = temperatureFormat
        
        params["units"] = temperatureFormat.rawValue
        params["lang"] = lang.rawValue
    }
}

// MARK: Private functions
extension WAPIManager {
    internal func apiCall(method: Router, response: @escaping (WeatherResult) -> Void) {
        
        Alamofire.request(method).responseJSON { rs in
            guard let js: Any = rs.result.value, rs.result.isSuccess else {
                response(WeatherResult.Error(rs.result.error.debugDescription))
                return
            }
            response(WeatherResult.Success(JSON(js)))
        }
    }
}

enum Router: URLRequestConvertible {
    static let baseURLString = "http://api.openweathermap.org/data/"
    static let apiVersion = "2.5"
    
    case Weather([String: Any])
    case ForeCast([String: Any])
    case DailyForecast([String: Any])
    case HirstoricData([String: Any])
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .Weather:
            return "/weather"
        case .ForeCast:
            return "/forecast"
        case .DailyForecast:
            return "/forecast/daily"
        case .HirstoricData:
            return "/history/city"
        }
    }
    
    
    func encode(params: [String: Any]) -> URLRequest {
        
        let url = URL(string:  Router.baseURLString + Router.apiVersion)
        let urlRequest = URLRequest(url: (url?.appendingPathComponent(path))!)
        
        return try! URLEncoding().encode(urlRequest, with: params)
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .Weather(let parameters):
            return encode(params: parameters)
        case .ForeCast(let parameters):
            return encode(params: parameters)
        case .DailyForecast(let parameters):
            return encode(params: parameters)
        case .HirstoricData(let parameters):
            return encode(params: parameters)
        }
    }
}


//MARK: - Get Current Weather
extension WAPIManager {
    
    private func currentWeather(params: [String:Any], data: @escaping (WeatherResult) -> Void) {
        apiCall(method: Router.Weather(params)) { data($0) }
    }
    
    public func currentWeatherByCityNameAsJson(cityName: String, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName
        
        currentWeather(params: params) { data($0) }
    }
    
    public func currentWeatherByCoordinatesAsJson(coordinates: CLLocationCoordinate2D, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude)
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude)
        
        currentWeather(params: params) { data($0) }
    }
}

//MARK: - Get Forecast
extension WAPIManager {
    
    private func forecastWeather(parameters: [String:Any], data: @escaping (WeatherResult) -> Void) {
        apiCall(method: Router.ForeCast(params)) { data($0) }
    }
    
    public func forecastWeatherByCityNameAsJson(cityName: String, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName
        
        forecastWeather(parameters: params) { data($0) }
    }
    
    public func forecastWeatherByCoordinatesAsJson(coordinates: CLLocationCoordinate2D, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude)
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude)
        
        forecastWeather(parameters: params) { data($0) }
    }
}

//MARK: - Get Daily Forecast
extension WAPIManager {
    
    private func dailyForecastWeather(parameters: [String:Any], data: @escaping (WeatherResult) -> Void) {
        apiCall(method: Router.DailyForecast(params)) { data($0) }
    }
    
    public func dailyForecastWeatherByCityNameAsJson(cityName: String, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName
        
        dailyForecastWeather(parameters: params) { data($0) }
    }
    
    public func dailyForecastWeatherByCoordinatesAsJson(coordinates: CLLocationCoordinate2D, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude)
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude)
        
        dailyForecastWeather(parameters: params) { data($0) }
    }
    
}


//MARK: - Get Historic Data
extension WAPIManager {
    
    private func historicData(parameters: [String:Any], data: @escaping (WeatherResult) -> Void) {
        params["type"] = "hour"
        
        apiCall(method: Router.HirstoricData(params)) { data($0) }
    }
    
    public func historicDataByCityNameAsJson(cityName: String, start: NSDate, end: NSDate?, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName
        
        params["start"] = start.timeIntervalSince1970
        if let endDate = end {
            params["end"] = endDate.timeIntervalSince1970
        }
        
        historicData(parameters: params) { data($0) }
    }
    
    public func historicDataByCoordinatesAsJson(coordinates: CLLocationCoordinate2D, start: NSDate, end: NSDate?, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude)
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude)
        
        params["start"] = start.timeIntervalSince1970
        if let endDate = end {
            params["end"] = endDate.timeIntervalSince1970
        }
        
        historicData(parameters: params) { data($0) }
    }
    
}

