//
//  ViewController.swift
//  Pixel-city
//
//  Created by Roman Tuzhilkin on 7/20/20.
//  Copyright © 2020 Roman Tuzhilkin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var imageNameArray = [String]()
    
    
    var screenSize = UIScreen.main.bounds
    
    var pinCoordinate: CLLocationCoordinate2D!
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    //_________________________________________________________________
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: CONSTANTS.instance.cellIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionView?.backgroundColor = UIColor.white
        
        registerForPreviewing(with: self, sourceView: collectionView!)
        
        photosView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    func addSwipeDown() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        photosView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = CGFloat(CONSTANTS.instance.mapViewMoveUpFor)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 1
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        if pinCoordinate != nil {
            let coordinateRegion = MKCoordinateRegion(center: pinCoordinate, latitudinalMeters: CONSTANTS.instance.regionRadius * 2, longitudinalMeters: CONSTANTS.instance.regionRadius * 2)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        
        imageUrlArray = []
        imageArray = []
        imageNameArray = []
        
        collectionView?.reloadData()
    }

    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = UIActivityIndicatorView.Style.large
        spinner?.color = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    func addProgressLbl() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 100, y: 180, width: 200, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
    
    @IBAction func centerMapButtonPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUser()
            animateViewDown()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: CONSTANTS.instance.pinIdentifier)
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    func centerMapOnUser() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: CONSTANTS.instance.regionRadius * 2, longitudinalMeters: CONSTANTS.instance.regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
                
        removePin()
        removeSpinner()
        removeProgressLbl()
        
        imageUrlArray = []
        imageArray = []
        imageNameArray = []
        collectionView?.reloadData()
        
        cancelAllSessions()
        
        animateViewUp()
        addSwipeDown()
        addSpinner()
        addProgressLbl()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoorditane = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        pinCoordinate = touchCoorditane
        
        let annotation = DroppablePin(coordinate: touchCoorditane, identifier: CONSTANTS.instance.pinIdentifier)
        mapView.addAnnotation(annotation)
        
        
        let pinnedRegion = MKCoordinateRegion(center: touchCoorditane, latitudinalMeters: CONSTANTS.instance.pinnedRegionRadius, longitudinalMeters: CONSTANTS.instance.pinnedRegionRadius)
        mapView.setRegion(pinnedRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { finished in
            if finished {
                self.retrieveImages( handler: { finished in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func removeProgressLbl() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        imageUrlArray = []

        AF.request(CONSTANTS.instance.flickrURL(forApiKey: CONSTANTS.instance.apiKey, withAnnotation: annotation, andNumberOfPhotos: 35)).responseJSON { (response) in
            guard let json = response.value as? Dictionary<String, AnyObject> else { return }
            let photoDictionary = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictionaryArray = photoDictionary["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictionaryArray {
                
//https://live.staticflickr.com/\(obj["server"]!)/\(obj["id"]!)_\(obj["secret"]!)_b_d.jpg"
                
                let postUrl = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_b_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            
            for picture in photosDictionaryArray {
                if picture["title"]  == nil {
                    self.imageNameArray.append("")
                }
                else {
                self.imageNameArray.append(picture["title"] as! String)
                }
            }
            handler(true)
        }
    }
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        imageArray = []
        
        for url in imageUrlArray {
            AF.request(url).responseImage(completionHandler: { response in
                guard let image = response.value else { return }
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/35 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSessions() {
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
        
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUser()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of items
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CONSTANTS.instance.cellIdentifier, for: indexPath) as? PhotoCell else { return UICollectionViewCell()}
        
        let imageFormIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFormIndex)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        cell.addSubview(imageView)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(identifier: CONSTANTS.instance.popVCIdentivier) as? _DPopVC else { return }
        popVC.initpassedData(forImage: imageArray[indexPath.row], forTitle: imageNameArray[indexPath.row], forLocation: pinCoordinate)
        present(popVC, animated: true, completion: nil)
    }
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil}
        
        guard let popVC = storyboard?.instantiateViewController(identifier: CONSTANTS.instance.popVCIdentivier) as? _DPopVC else { return nil }
        
        popVC.initpassedData(forImage: imageArray[indexPath.row], forTitle: imageNameArray[indexPath.row], forLocation: pinCoordinate)
        
        previewingContext.sourceRect = cell.contentView.frame
        
        return popVC
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
