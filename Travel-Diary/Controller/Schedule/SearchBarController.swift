//
//  SearchBarController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/18.
//

import UIKit
import MapKit

protocol HandleScheduleDelegate: AnyObject {
    func returnMark(mark: Spot, section: Int)
}

class SearchBarController: UIViewController {
    weak var delegate: HandleScheduleDelegate?
    
    var resultSearchController: UISearchController?
    let mapView = MKMapView()
    var daySection: Int?
    let animationView = LottieAnimation.shared.createLoopAnimation(lottieName: "search")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(mapView)
        mapView.alpha = 0.5
        mapView.addConstraintsToFillView(view)
        mapView.addSubview(animationView)
        animationView.center(inView: mapView)

        setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - search
    func setSearchBar() {
        let searchTable = SearchResultController()
        resultSearchController = UISearchController(searchResultsController: searchTable)
        resultSearchController?.searchResultsUpdater = searchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search places to add"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        searchTable.delegate = self
        searchTable.mapView = mapView
    }
}

extension SearchBarController: HandleMapSearchDelegate {
    func getSearchResult(placemark: Spot) {
        self.delegate?.returnMark(mark: placemark, section: daySection ?? 0)
        navigationController?.popViewController(animated: true)
    }
}
