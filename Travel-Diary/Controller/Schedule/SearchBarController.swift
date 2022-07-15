//
//  SearchBarController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/18.
//

import UIKit
import MapKit
import SwiftUI

protocol HandleScheduleDelegate: AnyObject {
    func returnMark(mark: Spot, section: Int)
}

class SearchBarController: UIViewController {
    weak var delegate: HandleScheduleDelegate?
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapBack))
        button.tintColor = .customBlue
        return button
    }()
    
    var resultSearchController: UISearchController?
    let mapView = MKMapView()
    var daySection: Int?
    
    let animationView = LottieAnimation.shared.createLoopAnimation(lottieName: "emptyAnimation")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setSearchBar()
    }
    
    func setupUI() {
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = .white
        
        view.addSubview(animationView)
        animationView.center(inView: view)
        animationView.setDimensions(width: UIScreen.width * 0.8, height: UIScreen.width * 0.8)
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
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension SearchBarController: HandleMapSearchDelegate {
    func getSearchResult(placemark: Spot) {
        self.delegate?.returnMark(mark: placemark, section: daySection ?? 0)
        navigationController?.popViewController(animated: true)
    }
}

extension SearchBarController: UIGestureRecognizerDelegate {

}
