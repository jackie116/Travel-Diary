//
//  PlaningController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import MapKit
import FloatingPanel

class ScheduleMapController: UIViewController {
    
    // MARK: - Properties
    lazy var navigationButton: UIButton = {
        let button = UIButton(frame: CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: 48, height: 48)))
        button.setBackgroundImage(UIImage.asset(.map), for: .normal)
        return button
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapBack))
        button.tintColor = .customBlue
        return button
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Pins")
        return mapView
    }()
    
    var tripData: Journey?
    
    var selectedPin: MKPlacemark?
    
    let lineColor: [UIColor] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    
    var annotationData = [DailySpot]()
    
    // MARK: - Lifecycle
    init(tripData: Journey) {
        self.tripData = tripData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavBar()
        hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavBar()
        showTabBar()
    }
    
    // MARK: - Helpers
    func setupUI() {
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.addSubview(mapView)
        setupConstraint()
        setupTitleView()
        setupScheduleUI()
    }
    
    func setupConstraint() {
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor,
                       bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func setupScheduleUI() {
        let scheduleVC = ScheduleController(tripData: tripData!)
        scheduleVC.delegate = self
        
        let panel = FloatingPanelController()
        panel.set(contentViewController: scheduleVC)
        panel.addPanel(toParent: self)
    }
    
    func setupTitleView() {
        guard let journey = tripData else { return }
        
        let title = journey.title
        let subtitle = Date.dateFormatter.string(from: Date.init(milliseconds: journey.start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journey.end))
        
        navigationItem.setTitle(title, subtitle: subtitle)
    }
    
    func placeAnnotation(offset: Int, mark: Spot) {
        let annotation = CustomAnnotation(coordinate: mark.coordinate.getCLLocationCoordinate2D())
        annotation.title = mark.name
        annotation.subtitle = "\(offset + 1)"
        mapView.addAnnotation(annotation)
    }
    
    func mapZoomIn(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func drawOverlay(offset: Int, marks: [Spot]) {
        var coordinates = [CLLocationCoordinate2D]()
        
        for mark in marks {
            coordinates.append(mark.coordinate.getCLLocationCoordinate2D())
        }
        
        let overlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        overlay.title = "\(offset)"
        self.mapView.addOverlay(overlay, level: .aboveRoads)
    }
    
    // MARK: - Selectors
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - DrawAnnotationDelegate
extension ScheduleMapController: DrawAnnotationDelegate {
    func zoomSelectedSpot(indexPath: IndexPath) {
        guard let zoomPoint = annotationData[safe: indexPath.section]?.spot[safe: indexPath.row]?
            .coordinate.getCLLocationCoordinate2D()
        else { return }
        mapZoomIn(coordinate: zoomPoint)
    }
    
    func zoomSelectedRoute(day: Int) {
        
        guard let zoomPoint = annotationData[safe: day]?.spot[safe: 0]?.coordinate.getCLLocationCoordinate2D()
        else { return }
        mapZoomIn(coordinate: zoomPoint)
    }
    
    func redrawMap(placemarks: [DailySpot]) {
        annotationData = placemarks
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        for marks in placemarks {
            for (offset, mark) in marks.spot.enumerated() {
                placeAnnotation(offset: offset, mark: mark)
            }
        }
    
        for (offset, marks) in placemarks.enumerated() {
            drawOverlay(offset: offset, marks: marks.spot)
        }
        
        guard let zoomPoint = placemarks[0].spot[safe: 0]?.coordinate.getCLLocationCoordinate2D() else { return }
        mapZoomIn(coordinate: zoomPoint)
    }
}

// MARK: - MKMapViewDelegate
extension ScheduleMapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Pins", for: annotation)
        
        guard let marker = view as? MKMarkerAnnotationView else { return view }
        marker.glyphText = annotation.subtitle as? String
        marker.subtitleVisibility = .hidden
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = navigationButton

        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        var colorTag = 0
        
        if let overlayTag = overlay.title {
            colorTag = (Int(overlayTag ?? "0") ?? 0) % lineColor.count
        }
        
        renderer.strokeColor = lineColor[colorTag]
        renderer.lineCap = .round
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let spot = view.annotation as? CustomAnnotation else { return }
        let placemark = MKPlacemark(coordinate: spot.coordinate)
        let targetItem = MKMapItem(placemark: placemark)
        targetItem.name = spot.title
        
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        targetItem.openInMaps(launchOptions: launchOptions)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ScheduleMapController: UIGestureRecognizerDelegate {

}
