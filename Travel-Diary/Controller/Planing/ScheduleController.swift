//
//  ScheduleController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/16.
//

import UIKit
import MapKit

protocol DrawAnnotationDelegate: AnyObject {
    func redrawMap(placemarks: [[CustomPlacemark]])
}

class ScheduleController: UIViewController {
    
    weak var delegate: DrawAnnotationDelegate?
    
    var tripData: NewTrip?
    
    var scheduleMarks: [[CustomPlacemark]] = [] {
        didSet {
            self.delegate?.redrawMap(placemarks: scheduleMarks)
        }
    }
    
    var sectionCollectionView: UICollectionView?
    
    private let topView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let scheduleTableView: UITableView = {
        let table = UITableView()
        
        table.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        table.register(ScheduleTableHeader.self, forHeaderFooterViewReuseIdentifier: ScheduleTableHeader.identifier)
        table.register(ScheduleSectionFooter.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionFooter.identifier)
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        scheduleTableView.dragDelegate = self
        scheduleTableView.dragInteractionEnabled = true
        
        initSchedule()
        setUI()
    }
    
    func initSchedule() {
        guard let days = tripData?.days else { return }
        for _ in 1...days {
            scheduleMarks.append([])
        }
    }
    
    func setUI() {
        view.addSubview(topView)
        topView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                       left: view.leftAnchor,
                       right: view.rightAnchor,
                       paddingTop: 20,
                       height: 50)
        
        view.addSubview(scheduleTableView)
        scheduleTableView.anchor(top: topView.bottomAnchor,
                                 left: view.leftAnchor,
                                 bottom: view.bottomAnchor,
                                 right: view.rightAnchor)
        
        setCollectionView()
    }
    
    func setCollectionView() {
        let layout = UICollectionViewFlowLayout()
        
        // 方向
        layout.scrollDirection = .horizontal
        // section 邊距
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        // size of each cell
        layout.itemSize = CGSize(width: 60, height: 40)
        // cell 間距
        layout.minimumLineSpacing = CGFloat(10)
        
        let rect = CGRect(x: 0, y: 0, width: UIScreen.width, height: 50)
        
        sectionCollectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        sectionCollectionView?.register(SectionCollectionCell.self,
                                        forCellWithReuseIdentifier: SectionCollectionCell.identifier)

        sectionCollectionView?.backgroundColor = .clear
        
        sectionCollectionView?.delegate = self
        sectionCollectionView?.dataSource = self
        // 分頁效果
        sectionCollectionView?.isPagingEnabled = true
        
        topView.addSubview(sectionCollectionView ?? UICollectionView())
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
    
    @objc func searchPlace(sender: UIButton) {
        let vc = SearchBarController()
        vc.daySection = sender.tag
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDragDelegate
extension ScheduleController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = scheduleMarks[indexPath.section][indexPath.row]
        return [dragItem]
    }
}

// MARK: - UITableViewDelegate
extension ScheduleController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ScheduleSectionFooter.identifier) as? ScheduleSectionFooter else {
            return UITableViewHeaderFooterView()
        }
        view.button.tag = section
        view.button.addTarget(self, action: #selector(searchPlace(sender:)), for: .touchUpInside)
        
        return view
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 刪除action
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { _, _, completionHandler in
            self.scheduleMarks[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        // Action 圖片
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        // 防止滑到底觸發刪除
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

// MARK: - UITableViewDataSource
extension ScheduleController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Day \(section + 1)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        scheduleMarks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scheduleMarks[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.identifier,
            for: indexPath) as? ScheduleCell else { return UITableViewCell() }
        cell.titleLabel.text = scheduleMarks[indexPath.section][indexPath.row].name
        cell.addressLabel.text = scheduleMarks[indexPath.section][indexPath.row].address
        cell.orderLabel.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = scheduleMarks[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        scheduleMarks[destinationIndexPath.section].insert(mover, at: destinationIndexPath.row)
        tableView.reloadData()
    }
}

// MARK: - HandleScheduleDelegate
extension ScheduleController: HandleScheduleDelegate {
    func returnMark(mark: CustomPlacemark, section: Int) {
        scheduleMarks[section].append(mark)
        scheduleTableView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension ScheduleController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tablePath = IndexPath(row: NSNotFound, section: indexPath.item)
        scheduleTableView.scrollToRow(at: tablePath, at: .top, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ScheduleController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        scheduleMarks.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SectionCollectionCell.identifier,
            for: indexPath) as? SectionCollectionCell else { return UICollectionViewCell() }
        
        cell.dayLabel.text = "Day \(indexPath.item + 1)"
        cell.backgroundColor = .customBlue
        
        return cell
    }
}
