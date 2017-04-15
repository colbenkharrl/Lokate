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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryText: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var result: Result = Result()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        titleLabel.text = result.title
        summaryText.text = result.summary
                
        mapView.mapType = MKMapType.hybrid
        let coordinates = CLLocationCoordinate2D( latitude: result.latitude, longitude: result.longitude)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.02, 0.02)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinates, span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = result.title
        mapView.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "wiki"{
            if let wikiVC: WebViewController = segue.destination as? WebViewController {
                wikiVC.urlString = result.url
            }
        }
    }
    
}
