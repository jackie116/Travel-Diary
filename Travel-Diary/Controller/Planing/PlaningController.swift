//
//  PlaningController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import MapKit
import FloatingPanel

protocol HandleScheduleDelegate: AnyObject {
    
}

class PlaningController: UIViewController {
    
    var tripName: String?
    var startTimeInterval: TimeInterval?
    var endTimeInterval: TimeInterval?
    
    // MARK: - search
    var resultSearchController: UISearchController?
    var selectedPin: MKPlacemark?
    weak var delegate: HandleScheduleDelegate?
    
    let mapView = MKMapView()
    
    private lazy var addSpotButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add New Attraction", for: .normal)
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(addNewSpot), for: .touchUpInside)
        return button
    }()
    
    private lazy var scheduleVC = ScheduleController()
    
    var barAppearance = UINavigationBarAppearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 透明Navigation Bar
        barAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        barAppearance.configureWithDefaultBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
    }
    
    func setUI() {
        setMapUI()
        setScheduleUI()
    }
    
    // MARK: - search
    func setSearchBar() {
        let searchTable = SearchPlaceController()
        resultSearchController = UISearchController(searchResultsController: searchTable)
        resultSearchController?.searchResultsUpdater = searchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search places to add"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
        searchTable.mapView = mapView
        searchTable.delegate = self
    }
    
    func setMapUI() {
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor,
                       bottom: view.bottomAnchor, right: view.rightAnchor,
                       paddingTop: 0, paddingLeft: 0,
                       paddingBottom: 0, paddingRight: 0)
    }
    
    func setScheduleUI() {
        let panel = FloatingPanelController()
        panel.set(contentViewController: scheduleVC)
        panel.addPanel(toParent: self)
    }
    
    @objc func addNewSpot() {
        let vc = SearchPlaceController()
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true)
    }
}

extension PlaningController: HandleMapSearchDelegate {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        
        //mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
