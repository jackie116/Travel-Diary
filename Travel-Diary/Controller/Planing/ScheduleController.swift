//
//  ScheduleController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/16.
//

import UIKit
import MapKit

// TODO: - zoomSelectedSpot 
protocol DrawAnnotationDelegate: AnyObject {
    func redrawMap(placemarks: [DailySpot])
    func zoomSelectedRoute(day: Int)
}

class ScheduleController: UIViewController {
    
    weak var delegate: DrawAnnotationDelegate?
    
    var tripData: Journey?
    
    var scheduleMarks: [DailySpot] = [] {
        didSet {
            self.tripData?.data = scheduleMarks
            self.delegate?.redrawMap(placemarks: scheduleMarks)
        }
    }
    
    lazy var sectionCollectionView: UICollectionView = {
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
        
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        
        collectionView.register(SectionCollectionCell.self,
                                        forCellWithReuseIdentifier: SectionCollectionCell.identifier)

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.isPagingEnabled = true
        
        return collectionView
    }()
    
    private let topView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var scheduleTableView: UITableView = {
        let table = UITableView()
        
        table.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        table.register(ScheduleTableHeader.self, forHeaderFooterViewReuseIdentifier: ScheduleTableHeader.identifier)
        table.register(ScheduleSectionFooter.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionFooter.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.dragDelegate = self
        table.dragInteractionEnabled = true
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSchedule()
        setUI()
    }
    
    func initSchedule() {
        guard let tripData = tripData else { return }
        
        if tripData.data.isEmpty {
            for _ in 1...tripData.days {
                scheduleMarks.append(DailySpot())
            }
        } else {
            scheduleMarks = tripData.data
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
        setScheduleTableHeaderFooter()
        
        setCollectionView()
    }
    
    func setScheduleTableHeaderFooter() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
        
        let tripTitle: UILabel = {
            let label = UILabel()
            label.text = self.tripData?.title
            return label
        }()
        
        let tripDuration: UILabel = {
            let label = UILabel()
            label.text = self.getTripDuration(
                start: self.tripData?.start ?? 0,
                end: self.tripData?.end ?? 0)
            return label
        }()
        
        headerView.addSubview(tripTitle)
        headerView.addSubview(tripDuration)
        
        tripTitle.anchor(top: headerView.topAnchor,
                         left: headerView.leftAnchor,
                         right: headerView.rightAnchor,
                         paddingTop: 8, paddingLeft: 16,
                         paddingRight: 16)
        
        tripDuration.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tripDuration.topAnchor.constraint(equalTo: tripTitle.bottomAnchor, constant: 8),
            tripDuration.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16),
            tripDuration.bottomAnchor.constraint(greaterThanOrEqualTo: headerView.bottomAnchor, constant: -16),
            tripDuration.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: 16)
        ])
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        
        let uploadButton: UIButton = {
            let button = UIButton()
            button.setTitle("Upload", for: .normal)
            button.backgroundColor = .customBlue
            button.addTarget(self, action: #selector(uploadSchedule), for: .touchUpInside)
            return button
        }()
        
        footerView.addSubview(uploadButton)
        uploadButton.centerX(inView: footerView)
        uploadButton.centerY(inView: footerView)
        uploadButton.setDimensions(width: 80, height: 40)
        
        scheduleTableView.tableHeaderView = headerView
        scheduleTableView.tableFooterView = footerView
    }
    
    func setCollectionView() {
        topView.addSubview(sectionCollectionView)
    }
    
    func getTripDuration(start: Int64, end: Int64) -> String {
        return "\(int64ToyMd(start)) - \(int64ToyMd(end))"
    }
    
    private func int64ToyMd(_ timestamp: Int64) -> String {
        let date = Date(milliseconds: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    @objc func searchPlace(_ sender: UIButton) {
        let vc = SearchBarController()
        vc.daySection = sender.tag
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func uploadSchedule() {
        JourneyManager.shared.updateJourney(journey: self.tripData!) { result in
            switch result {
            case .success:
                print("Upload success")
            case .failure(let error):
                print("Upload failure: \(error)")
            }
        }
    }
}

// MARK: - UITableViewDragDelegate
extension ScheduleController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = scheduleMarks[indexPath.section].spot[indexPath.row]
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
        view.button.addTarget(self, action: #selector(searchPlace), for: .touchUpInside)
        
        return view
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 刪除action
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { _, _, completionHandler in
            self.scheduleMarks[indexPath.section].spot.remove(at: indexPath.row)
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
        scheduleMarks[section].spot.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.identifier,
            for: indexPath) as? ScheduleCell else { return UITableViewCell() }
        cell.titleLabel.text = scheduleMarks[indexPath.section].spot[indexPath.row].name
        cell.addressLabel.text = scheduleMarks[indexPath.section].spot[indexPath.row].address
        cell.orderLabel.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = scheduleMarks[sourceIndexPath.section].spot.remove(at: sourceIndexPath.row)
        scheduleMarks[destinationIndexPath.section].spot.insert(mover, at: destinationIndexPath.row)
        tableView.reloadData()
    }
}

// MARK: - HandleScheduleDelegate
extension ScheduleController: HandleScheduleDelegate {
    func returnMark(mark: Spot, section: Int) {
        scheduleMarks[section].spot.append(mark)
        scheduleTableView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension ScheduleController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tablePath = IndexPath(row: NSNotFound, section: indexPath.item)
        scheduleTableView.scrollToRow(at: tablePath, at: .top, animated: true)
        self.delegate?.zoomSelectedRoute(day: indexPath.item)
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
