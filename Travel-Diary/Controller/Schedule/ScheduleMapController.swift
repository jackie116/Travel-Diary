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
    
    lazy var navigationButton: UIButton = {
        let button = UIButton(frame: CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: 48, height: 48)))
        button.setBackgroundImage(UIImage(named: "Map"), for: .normal)
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
    
    var tripData: Journey?
    
    var selectedPin: MKPlacemark?
    
    let mapView = MKMapView()
    
    let lineColor: [UIColor] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    
    var annotationData = [DailySpot]()
    
    private lazy var scheduleVC = ScheduleController()
    
    var barAppearance = UINavigationBarAppearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Pins")
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
        navigationItem.leftBarButtonItem = backButton
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
        scheduleVC.delegate = self
        scheduleVC.tripData = tripData
        
        let panel = FloatingPanelController()
        panel.set(contentViewController: scheduleVC)
        panel.addPanel(toParent: self)
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
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

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

extension ScheduleMapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Pins", for: annotation)
        
        guard let marker = view as? MKMarkerAnnotationView else { return view}
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
