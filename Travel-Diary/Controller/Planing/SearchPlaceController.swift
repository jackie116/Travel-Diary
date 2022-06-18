//
//  SearchPlaceController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/16.
//

import UIKit
import MapKit

// MARK: - search
protocol HandleMapSearchDelegate: AnyObject {
    func dropPinZoomIn(placemark: CustomPlacemark)
}

class SearchPlaceController: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    weak var delegate: HandleMapSearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SearchPlaceCell.self, forCellReuseIdentifier: SearchPlaceCell.identifier)
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        var addressLine: String = ""
        if selectedItem.subThoroughfare != nil {
            addressLine = selectedItem.subThoroughfare! + " "
        }
        if selectedItem.thoroughfare != nil {
            addressLine += selectedItem.thoroughfare! + ", "
        }
        if selectedItem.locality != nil {
            addressLine += selectedItem.locality! + ", "
        }
        if selectedItem.administrativeArea != nil {
            addressLine += selectedItem.administrativeArea! + " "
        } else if selectedItem.subAdministrativeArea != nil {
            addressLine += selectedItem.subAdministrativeArea! + " "
        }
        
        if selectedItem.postalCode != nil {
            addressLine += selectedItem.postalCode! + " "
        }
        if selectedItem.isoCountryCode != nil {
            addressLine += selectedItem.isoCountryCode!
        }
        return addressLine
    }
}

extension SearchPlaceController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension SearchPlaceController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchPlaceCell.identifier,
            for: indexPath) as? SearchPlaceCell else { return UITableViewCell() }
        
        let selectedItem = matchingItems[indexPath.row].placemark
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "mappin.and.ellipse")
        content.text = selectedItem.name
        content.secondaryText = parseAddress(selectedItem: selectedItem)
        cell.contentConfiguration = content
        
        return cell
    }
}

extension SearchPlaceController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        let spot = CustomPlacemark(name: selectedItem.name ?? "",
                                   address: parseAddress(selectedItem: selectedItem),
                                   coordinate: selectedItem.coordinate)
        self.delegate?.dropPinZoomIn(placemark: spot)
        dismiss(animated: true, completion: nil)
    }
}
