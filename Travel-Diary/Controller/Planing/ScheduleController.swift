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
    var spotInSchedule = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        scheduleTableView.register(SearchPlaceCell.self, forCellReuseIdentifier: SearchPlaceCell.identifier)
        
        setUI()
    }
    
    func setUI() {
        view.addSubview(scheduleTableView)
        scheduleTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 bottom: view.bottomAnchor,
                                 right: view.rightAnchor)
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
            withIdentifier: SearchPlaceCell.identifier,
            for: indexPath) as? SearchPlaceCell else { return UITableViewCell() }
        
        return cell
    }
}
