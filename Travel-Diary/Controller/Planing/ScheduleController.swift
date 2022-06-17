//
//  ScheduleController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/16.
//

import UIKit
import MapKit

class ScheduleController: UIViewController {
    
    private let scheduleTableView = UITableView()
    var spotInSchedule = [MKPlacemark]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        scheduleTableView.dragDelegate = self
        scheduleTableView.dragInteractionEnabled = true
        
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        
        setUI()
    }
    
    func setUI() {
        view.addSubview(scheduleTableView)
        scheduleTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 bottom: view.bottomAnchor,
                                 right: view.rightAnchor)
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

extension ScheduleController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = spotInSchedule[indexPath.row]
        return [dragItem]
    }
}

extension ScheduleController: UITableViewDelegate {
    
}

extension ScheduleController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        spotInSchedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.identifier,
            for: indexPath) as? ScheduleCell else { return UITableViewCell() }
        
        let selectedItem = spotInSchedule[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "mappin.and.ellipse")
        content.text = selectedItem.name
        content.secondaryText = parseAddress(selectedItem: selectedItem)
        cell.contentConfiguration = content
        cell.showsReorderControl = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        spotInSchedule.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        print(spotInSchedule)
    }
}

extension ScheduleController: HandleScheduleDelegate {
    func passPlacemark(placemark: MKPlacemark) {
        spotInSchedule.append(placemark)
        scheduleTableView.reloadData()
    }
}
