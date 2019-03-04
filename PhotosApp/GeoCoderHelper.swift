//
//  GeoCoderHelper.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation

class GeoCoderHelper: NSObject {
    
    static let shared = GeoCoderHelper()
    
    struct GeocoderConfig {
        
        static let APIkey               = "ADD"
        
        // Paths
        
        static let baseURL              = URL(string: "https://maps.googleapis.com/maps/api")!
        static let pathGeocoder         = "geocode"
        static let pathJson             = "json"
        static let pathStaticMap        = "staticmap"
        
        // Query
        
        static let latLng               = "latlng"
        static let language             = "language"
        static let region               = "region"
        static let key                  = "key"
        static let center               = "center"
        static let zoom                 = "zoom"
        static let size                 = "size"
        static let scale                = "scale"
        static let maptype              = "maptype"
        static let markers              = "markers"
        static let label                = "label"
        static let icon                 = "icon"
        
        // Result keys
        
        static let results              = "results"
        static let status               = "status"
        static let OK                   = "OK"
        static let addressComponents    = "address_components"
        static let longName             = "long_name"
        static let shortName            = "short_name"
        static let types                = "types"
        static let country              = "country"
        static let streetAddress        = "street_address"
        static let formattedAddress     = "formatted_address"
        static let route                = "route"
        
        // Parameter values
        
        static let scale2               = "2"
        static let roadmap              = "roadmap"
        static let satellite            = "satellite"
        static let hybrid               = "hybrid"
        static let terrain              = "terrain"
    }
    
    private var addressCache = NSCache<AnyObject, AnyObject>()
    
    private var _currentCountry: String?
    var currentCountry: String? {
        
        get {
            
            return _currentCountry
        }
    }
    
    override init() {
        
        super.init()
        
        signupForMemoryWarningNotification()
    }
    
    deinit {
        
        resignFromMemoryWarningNotification()
    }
    
    func reverseGeocode(for coordinate: CLLocationCoordinate2D, completion: ((_ address: String?, _ error: NSError?) ->())?) {
        
        print("Reverse geocoding for \(coordinate.latitude).\(coordinate.longitude)")
        
        if let cached = cachedAddress(for: coordinate) {
            
            completion?(cached, nil)
        }
        else {
            
            fetch(for: coordinate, with: { (results, error) in
                
                if error != nil || results == nil {
                    
                    completion?(nil, error as NSError?)
                }
                else {
                    
                    let address = results?.first?[GeocoderConfig.formattedAddress] as? String
                    
                    completion?(address, nil)
                }
            })
        }
    }
    
    func cachedAddress(for location: CLLocationCoordinate2D) -> String? {
        
        let coordString = String(coordinate: location, separator: ".")
        
        if let address = addressCache.object(forKey: coordString as AnyObject) as? String {
            
            return address
        }
        
        return nil
    }
    
    private func cache(_ address: String, coordinate: CLLocationCoordinate2D) {
        
        let coordString = String(coordinate: coordinate, separator: ".")
        
        addressCache.setObject(coordString as AnyObject, forKey: coordinate as AnyObject)
    }
    
    func reverseGeocodeCountry(for coordinate: CLLocationCoordinate2D, completion: ((_ country: String?, _ error: NSError?) ->())?) {
        
        if let country = _currentCountry {
            
            completion?(country, nil)
        }
        else {
            
            fetch(for: coordinate, with: { (results, error) in
                
                if results != nil {
                    
                    for result in results! {
                        
                        if let types = result[GeocoderConfig.types] as? [String], let components = result[GeocoderConfig.addressComponents] as? [[String: Any]] {
                            
                            if types.contains(GeocoderConfig.country), let shortName = components.first?[GeocoderConfig.shortName] as? String {
                                
                                self._currentCountry = shortName
                                break
                            }
                        }
                    }
                }
            })
        }
    }
    
    internal lazy var defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    private func fetch(for coordinate: CLLocationCoordinate2D, with completion: ((_ results: [[String: Any]]?, _ error: Error?) -> ())?) {
        
        let url = GeocoderConfig.baseURL.appendingPathComponent(GeocoderConfig.pathGeocoder).appendingPathComponent(GeocoderConfig.pathJson).appendingLatLng(from: coordinate).appendingRegion().appendingLanguage().appendingAPIKey()
        
        let dataTask = defaultSession.dataTask(with: url, completionHandler: { (data, response, error) in
            
            #if DEBUG
            let httpCode = response != nil ? (response as! HTTPURLResponse).statusCode : -666
            let dataString = data != nil ? String(data: data!, encoding: .utf8) : "EMPTY"
            print("\(url.absoluteString) -> \(httpCode)\n\(dataString ?? "EMPTY"), error: \(String(describing: error))")
            #endif
            
            if error != nil {
                
                completion?(nil, error)
            }
            else {
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                    
                    if let results = json?[GeocoderConfig.results] as? [[String: Any]] {
                        
                        completion?(results, nil)
                    }
                    else {
                        
                        completion?(nil, nil)
                    }
                    
                }
                catch let error2 {
                    
                    completion?(nil, error2)
                }
            }
        })
        
        dataTask.resume()
    }
    
    // MARK: - Memory warning
    
    private func signupForMemoryWarningNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMemoryWarningNotification(notification:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc func didReceiveMemoryWarningNotification(notification: Notification) {
        
        addressCache.removeAllObjects()
    }
    
    private func resignFromMemoryWarningNotification() {
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    // MARK: - Static map
    
    class func constructStaticMapURL(coordinate: CLLocationCoordinate2D, width: CGFloat, height: CGFloat, doubleScale: Bool, zoom: Int, mapType: String?, markerTitle: String?, markerIconUrl: String?) -> URL {
        
        var url = GeocoderConfig.baseURL.appendingPathComponent(GeocoderConfig.pathStaticMap)
            .appendingLatLng(coordinate: coordinate, param: GeocoderConfig.center)
            .appendingLanguage()
            .appendingAPIKey()
            .appendQueryItem(with: GeocoderConfig.zoom, value: String(zoom))
            .appendingRegion()
            .appendQueryItem(with: GeocoderConfig.maptype, value: mapType != nil ? mapType! : GeocoderConfig.roadmap)
        
        if doubleScale {
            
            url = url.appendQueryItem(with: GeocoderConfig.scale, value: GeocoderConfig.scale2)
        }
        
        var markers = ""
        
        if markerIconUrl != nil && markerIconUrl!.count > 0 {
            
            markers += GeocoderConfig.icon + ":" + markerIconUrl!
        }
        
        if markerTitle != nil && markerTitle!.count > 0 {
            
            if markers.count > 0 {
                
                markers += "|"
            }
            
            markers += GeocoderConfig.label + ":" + markerTitle!
        }
        
        if markers.count > 0 {
            
            markers += "|"
        }
        
        markers += String(coordinate: coordinate)
        
        url = url.appendQueryItem(with: GeocoderConfig.markers, value: markers)
        
        if width > 0 && height > 0 {
            
            url = url.appendQueryItem(with: GeocoderConfig.size, value: String(format: "%ldx%ld", Int(width), Int(height)))
        }
        
        return url
    }
}

extension URL {
    
    func appendQueryItem(with name: String, value: String) -> URL {
        
        let queryItem = URLQueryItem(name: name, value: value)
        
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        if urlComponents.queryItems != nil {
            
            urlComponents.queryItems?.append(queryItem)
        }
        else {
            urlComponents.queryItems = [queryItem]
        }
        
        let url = urlComponents.url!
        
        return url
    }
    
    func appendingLatLng(coordinate: CLLocationCoordinate2D, param: String) -> URL {
        
        let latLngString = String(coordinate: coordinate)
        
        return appendQueryItem(with: param, value: latLngString)
    }
    
    func appendingLatLng(from coordinate: CLLocationCoordinate2D) -> URL {
        
        return appendingLatLng(coordinate: coordinate, param: GeoCoderHelper.GeocoderConfig.latLng)
    }
    
    func appendingLanguage() -> URL {
        
        if let langCode = NSLocale.current.languageCode {
            
            return appendQueryItem(with: GeoCoderHelper.GeocoderConfig.language, value: langCode)
        }
        
        return self
    }
    
    func appendingRegion() -> URL {
        
        if let country = GeoCoderHelper.shared.currentCountry {
            
            return appendQueryItem(with: GeoCoderHelper.GeocoderConfig.region, value: country)
        }
        
        return self
    }
    
    func appendingAPIKey() -> URL {
        
        return appendQueryItem(with: GeoCoderHelper.GeocoderConfig.key, value: GeoCoderHelper.GeocoderConfig.APIkey)
    }
}
