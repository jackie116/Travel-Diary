//
//  BaseTableViewController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/28.
//

import UIKit

class BaseTableViewController: UIViewController {
    
    // MARK: - Properties
    lazy var tableView: UITableView = {
        let table = UITableView()

        table.estimatedRowHeight = UIScreen.height / 3
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear

        return table
    }()
    
    lazy var refreshControl = UIRefreshControl()

    let backgroundStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()

    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "gy_eat")
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.alpha = 0.5
        return view
    }()

    let backgroundLabel: UILabel = {
        let label = UILabel()
        label.text = "No journey exist"
        label.alpha = 0.5
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Helpers
    func setupUI() {
        view.backgroundColor = .white
        backgroundStackView.addArrangedSubview(backgroundImageView)
        backgroundStackView.addArrangedSubview(backgroundLabel)
        view.addSubview(backgroundStackView)
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
    
        setupConstraint()
    }
    
    func setupConstraint() {
        backgroundImageView.setDimensions(width: UIScreen.width * 0.6, height: UIScreen.width * 0.6)
        backgroundStackView.center(inView: view)
        
        tableView.addConstraintsToFillSafeArea(view)
    }
    
    func fetchData() {
        
    }
    
    // MARK: - Selectors
    @objc func refreshTable() {
        fetchData()
    }
}
