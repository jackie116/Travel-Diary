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
        scheduleVC.delegate = self
        scheduleVC.tripData = tripData
        
        let panel = FloatingPanelController()
        panel.set(contentViewController: scheduleVC)
        panel.addPanel(toParent: self)
    }
    
    func placeAnnotation(mark: Spot) {
        let annotation = CustomAnnotation(coordinate: mark.coordinate.getCLLocationCoordinate2D())
        annotation.title = mark.name
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
            for mark in marks.spot {
                placeAnnotation(mark: mark)
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
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        guard let pin = annotation as? CustomAnnotation else { return MKAnnotationView() }
//
//        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "Pins")
//
//        if view == nil {
//            view = MKAnnotationView(annotation: pin, reuseIdentifier: "Pins")
//            view?.image = UIImage(named: "pin")
//            view?.canShowCallout = true
//        }
//
//        return view
//    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        var colorTag = 0
        
        if let overlayTag = overlay.title {
            colorTag = (Int(overlayTag ?? "0") ?? 0) % lineColor.count
        }
        
        renderer.strokeColor = lineColor[colorTag]
        renderer.lineCap = .round
        renderer.lineWidth = 3.0
        
        return renderer
    }
}
