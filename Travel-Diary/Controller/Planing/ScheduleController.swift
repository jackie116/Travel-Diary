//
//  ScheduleController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/16.
//

import UIKit
import MapKit

class ScheduleController: UIViewController {
    
    var tripName: String?
    var startTimeInterval: TimeInterval?
    var endTimeInterval: TimeInterval?
    
    private let scheduleTableView: UITableView = {
        let table = UITableView()
        
        table.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        
        table.register(ScheduleTableHeader.self, forHeaderFooterViewReuseIdentifier: ScheduleTableHeader.identifier)
        
        return table
    }()
    
    var spotInSchedule = [MKPlacemark]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        scheduleTableView.dragDelegate = self
        scheduleTableView.dragInteractionEnabled = true
        
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
    
    func getTripDuration(start: TimeInterval, end: TimeInterval) -> String {
        return timeIntervalToString(timestamp: start) + " - " + timeIntervalToString(timestamp: end)
    }
    
    private func timeIntervalToString(timestamp: TimeInterval) -> String {
        let timeInterval = TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

// drag and reorder cell
extension ScheduleController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = spotInSchedule[indexPath.row]
        return [dragItem]
    }
}

extension ScheduleController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ScheduleTableHeader.identifier) as? ScheduleTableHeader
        
        header?.titleLabel.text = tripName
        header?.tripDateLabel.text = getTripDuration(start: startTimeInterval ?? 0.0, end: endTimeInterval ?? 0.0)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        150.0
    }
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
        
//        var content = cell.defaultContentConfiguration()
//        content.image = UIImage(systemName: "mappin.and.ellipse")
//        content.text = selectedItem.name
//        content.secondaryText = parseAddress(selectedItem: selectedItem)
//        cell.contentConfiguration = content
//        cell.showsReorderControl = true
        cell.orderLabel.text = "\(indexPath.row)"
        cell.titleLabel.text = selectedItem.name
        cell.addressLabel.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    // cell drag and change data array order
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = spotInSchedule.remove(at: sourceIndexPath.row)
        spotInSchedule.insert(mover, at: destinationIndexPath.row)
        scheduleTableView.reloadData()
    }
}

// get new spot
extension ScheduleController: HandleScheduleDelegate {
    func passPlacemark(placemark: MKPlacemark) {
        spotInSchedule.append(placemark)
        scheduleTableView.reloadData()
    }
}
