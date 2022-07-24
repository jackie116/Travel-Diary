//
//  ScheduleController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/16.
//

import UIKit
import MapKit
 
protocol DrawAnnotationDelegate: AnyObject {
    func redrawMap(placemarks: [DailySpot])
    func zoomSelectedRoute(day: Int)
    func zoomSelectedSpot(indexPath: IndexPath)
}

class ScheduleController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: DrawAnnotationDelegate?
    
    // MARK: - Properties
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let rect = CGRect(x: 0, y: 0, width: UIScreen.width, height: 50)
        
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        
        collectionView.register(DaysCell.self,
                                        forCellWithReuseIdentifier: DaysCell.identifier)

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        table.register(ScheduleSectionFooter.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionFooter.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.dragDelegate = self
        table.dragInteractionEnabled = true
        table.showsVerticalScrollIndicator = false
        
        return table
    }()

    var tripData: Journey?

    var scheduleMarks: [DailySpot] = [] {
        didSet {
            self.tripData?.data = scheduleMarks
            self.delegate?.redrawMap(placemarks: scheduleMarks)
        }
    }
    
    // MARK: - Lifecycle
    init(tripData: Journey) {
        self.tripData = tripData
        super.init(nibName: nil, bundle: nil)
        initSchedule()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        uploadSchedule()
    }
        
    // MARK: - Helpers
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
    
    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(tableView)
        
        setupConstraint()
    }
    
    func setupConstraint() {
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                       left: view.leftAnchor,
                       right: view.rightAnchor,
                       paddingTop: 20,
                       height: 50)
        
        tableView.anchor(top: collectionView.bottomAnchor,
                                 left: view.leftAnchor,
                                 bottom: view.bottomAnchor,
                                 right: view.rightAnchor)
    }

    private func uploadSchedule() {
        JourneyManager.shared.updateJourney(journey: self.tripData!) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                AlertHelper.shared.showAlert(title: "Upload Failed", message: error.localizedDescription, over: self)
            }
        }
    }
    
    // MARK: - Selectors
    @objc func searchPlace(_ sender: UIButton) {
        let vc = SearchBarController()
        vc.daySection = sender.tag
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func appMovedToBackground() {
        uploadSchedule()
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
                                              title: nil) { [weak self] _, _, completionHandler in
            self?.scheduleMarks[indexPath.section].spot.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        // 防止滑到底觸發刪除
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.zoomSelectedSpot(indexPath: indexPath)
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
        
        cell.setupData(name: scheduleMarks[indexPath.section].spot[indexPath.row].name,
                           address: scheduleMarks[indexPath.section].spot[indexPath.row].address,
                           order: indexPath.row)
        
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
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension ScheduleController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .customBlue
        cell?.isSelected = true
        let tablePath = IndexPath(row: NSNotFound, section: indexPath.item)
        tableView.scrollToRow(at: tablePath, at: .top, animated: true)
        self.delegate?.zoomSelectedRoute(day: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .clear
        cell?.isSelected = false
    }
}

// MARK: - UIcollectionViewDelegateFlowLayout
extension ScheduleController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.width / 5, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5.0
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
            withReuseIdentifier: DaysCell.identifier,
            for: indexPath) as? DaysCell else { return UICollectionViewCell() }
        
        cell.setupData(day: indexPath.item)
        
        return cell
    }
}
