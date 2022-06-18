//
//  PlaningController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import MapKit
import FloatingPanel

class PlaningController: UIViewController {
    
    var tripData: NewTrip?
    
    var selectedPin: MKPlacemark?
    
    let mapView = MKMapView()
    
    private lazy var scheduleVC = ScheduleController()
    
    var barAppearance = UINavigationBarAppearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 透明Navigation Bar
        barAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        barAppearance.configureWithDefaultBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setUI() {
        setMapUI()
        setScheduleUI()
    }
    
    func setMapUI() {
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor,
                       bottom: view.bottomAnchor, right: view.rightAnchor,
                       paddingTop: 0, paddingLeft: 0,
                       paddingBottom: 0, paddingRight: 0)
    }
    
    func setScheduleUI() {
        scheduleVC.tripData = tripData
        
        let panel = FloatingPanelController()
        panel.set(contentViewController: scheduleVC)
        panel.addPanel(toParent: self)
    }
}

extension PlaningController: HandleMapSearchDelegate {
    func dropPinZoomIn(placemark: CustomPlacemark) {
        // cache the pin
        // selectedPin = placemark
        
        // Add placemark to schedule array
        // self.delegate?.passPlacemark(placemark: placemark)
        // clear existing pins
        // mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        mapView.addAnnotation(annotation)
        // map zoom in
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
