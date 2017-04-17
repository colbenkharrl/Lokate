//
//  DetailViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/2/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    //      MEMBER DEF
    
    var result: Result = Result()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryText: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func mapTypeControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .hybrid
        }
    }
    
    //      INITIALIZATION

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeDisplay()
    }
    
    func initializeDisplay() {
        titleLabel.text = result.title
        summaryText.text = result.summary
        navigationItem.title = result.feature.capitalized
        initializeMap(lat: result.latitude, lon: result.longitude, title: result.title)
    }
    
    func initializeMap(lat: Double, lon: Double, title: String) {
        let coordinates = CLLocationCoordinate2D( latitude: lat, longitude: lon)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.02, 0.02)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinates, span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    //      SEGUE DEF
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "wiki"{
            if let wikiVC: WebViewController = segue.destination as? WebViewController {
                wikiVC.urlString = result.url
            }
        }
    }
    
}
