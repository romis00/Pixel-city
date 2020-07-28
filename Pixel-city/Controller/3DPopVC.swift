//
//  3DPopVC.swift
//  Pixel-city
//
//  Created by Roman Tuzhilkin on 7/23/20.
//  Copyright © 2020 Roman Tuzhilkin. All rights reserved.
//

import UIKit
import MapKit

class _DPopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var miniMap: MKMapView!
    
    var passedImage: UIImage!
    var passedTitle: String!
    var passedLocation: CLLocationCoordinate2D!
    
    func initpassedData(forImage image: UIImage, forTitle title: String, forLocation location: CLLocationCoordinate2D) {
        self.passedImage = image
        self.passedTitle = title
        self.passedLocation = location
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miniMap.delegate = self
        
        addDoubleTap()
        
        popImageView.image = passedImage
        titleLbl.text = passedTitle
        locateMiniMapForPinnedLocation()
        addPin()
    }
    
    func addDoubleTap() {
        let doubletap = UITapGestureRecognizer(target: self, action: #selector(screenWasDpubleTapped))
        
        doubletap.numberOfTapsRequired = 2
        doubletap.delegate = self
        view.addGestureRecognizer(doubletap)
    }
    
    @objc func screenWasDpubleTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func locateMiniMapForPinnedLocation() {
        let coordinateRegion = MKCoordinateRegion(center: passedLocation, latitudinalMeters: CONSTANTS.instance.miniMapRegionRadius, longitudinalMeters: CONSTANTS.instance.miniMapRegionRadius)
        miniMap.setRegion(coordinateRegion, animated: true)
    }
    
    func addPin() {
        let annotation = DroppablePin(coordinate: passedLocation, identifier: CONSTANTS.instance.miniMapPinIdentifier)
        miniMap.addAnnotation(annotation)
    }
    
    
}

extension _DPopVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let newPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: CONSTANTS.instance.miniMapPinIdentifier)
        newPin.pinTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        newPin.animatesDrop = true
        return newPin
    }
}
