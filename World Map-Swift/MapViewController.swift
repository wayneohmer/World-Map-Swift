//
//  ViewController.swift
//  MapboxStationFinder-Swift
//
//  Created by Wayne Ohmer on 5/7/15.
//  Copyright (c) 2015 Wayne Ohmer. All rights reserved.
//

import UIKit

class MapViewController: UIViewController  {

    var worldGeoJSON:GeoJSON?
    var countryDict:[String:[GeoJSON.GeoJSONFeature]!] = [:]
    @IBOutlet var mapView: RMMapView!
    @IBOutlet weak var countryField: UITextField!

    let sourceURL = "https://raw.githubusercontent.com/datasets/geo-boundaries-world-110m/master/countries.geojson"
//    let sourceURL = "https://raw.githubusercontent.com/johan/world.geo.json/6c1d099a452cbe5fe28dbef02759933d951a8904/countries.geo.json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RMConfiguration.sharedInstance().accessToken = "pk.eyJ1Ijoid2F5bmVvaG1lciIsImEiOiJqcHpkUFlVIn0.Ckoh0O9yUJ1E8WoFC8nhhg"
        self.mapView.tileSource = RMMapboxSource(mapID: "mapbox.pencil")
        self.mapView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.mapView.delegate = self
        self.mapView.zoom = 3

        GeoJSON.GeoJSONWithUrl(self.sourceURL) {(worldGeoJSON,error) -> Void in
            if (error == nil){
                self.worldGeoJSON = worldGeoJSON
                self.countryDict = worldGeoJSON.buildFeatureDictionaryWithPropertyString("name")
                dispatch_async(dispatch_get_main_queue()){
                    self.countryField.text = "China"
                    self.doneEditingCountryField(self.countryField)
                }
            }else{
                println(GeoJSONkeys.point)
            }
        }
    }
    //MARK: - keyboard delegate funcs

    @IBAction func doneEditingCountryField(sender: AnyObject) {
        self.mapView.removeAllAnnotations()
        func addAnnotationWithPolygon(polygon:[[CLLocation]]){
            for line in polygon{
                var countryAnnotation = RMAnnotation(mapView: self.mapView, coordinate: line[0].coordinate, andTitle: self.countryField.text)
                countryAnnotation.setBoundingBoxFromLocations(line)
                //userInfo is used to store "shape" array to be used in layerForAnnotation delegate func
                countryAnnotation.userInfo = line
                self.mapView!.addAnnotation(countryAnnotation)
            }
        }
        if let featureArray = self.countryDict[self.countryField.text] {
            for  feature in featureArray{
                self.mapView!.centerCoordinate = feature.geometry.center
                self.mapView.zoomWithLatitudeLongitudeBoundsSouthWest(feature.geometry.boundsSouthWest, northEast: feature.geometry.boundsNorthEast, animated: true)
                self.mapView.zoom = self.mapView.zoom - 0.3
                if feature.geometry.type == GeoJSONkeys.polygon{
                    addAnnotationWithPolygon(feature.geometry.polygon)
                }else if feature.geometry.type == GeoJSONkeys.multiPolygon{
                    for polygon in feature.geometry.multiPolygon{
                        addAnnotationWithPolygon(polygon)
                    }
                }
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MapView delegate 
extension MapViewController: RMMapViewDelegate {
    func singleTapOnMap(map: RMMapView!, at point: CGPoint) {
        let tapLocation = CLLocation(latitude:self.mapView.pixelToCoordinate(point).latitude,longitude:(self.mapView.pixelToCoordinate(point).longitude))
        if let featureArray = self.countryDict[self.countryField.text] {
            for  feature in featureArray{
                //check if tap was inside current country
                if (feature.geometry.surroundsPoint(tapLocation)){
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    var infoNavController = storyBoard.instantiateViewControllerWithIdentifier("InfoNavController") as! UINavigationController
                    var infoTableViewController = infoNavController.visibleViewController as! InfoTableViewController
                    for (key,value) in feature.stringProperties{
                        infoTableViewController.infoArray.append("\(key):\(value)")
                    }
                    infoNavController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                    self.presentViewController(infoNavController, animated: true, completion: nil)
                }
            }
        }
    }

    func mapView(mapView: RMMapView!, layerForAnnotation annotation:RMAnnotation) -> RMMapLayer {

        var shape = RMShape(view: self.mapView)
        shape.lineColor = UIColor.darkGrayColor()
        shape.lineWidth = 5.0
        for location in annotation.userInfo as! [CLLocation]{
            shape.addLineToCoordinate(location.coordinate)
        }
        return shape
    }
}