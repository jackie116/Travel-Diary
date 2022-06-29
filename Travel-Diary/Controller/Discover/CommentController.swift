//
//  CommentController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/26.
//

import UIKit

class CommentController: UIViewController {
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "send"), for: .normal)
        return button
    }()
    
    let buttomView: UIView = {
        let view = UIView()
        return view
    }()
    
    let commentView: UITextView = {
        let view = UITextView()
        return view
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 80
        table.rowHeight = UITableView.automaticDimension
        
        return table
    }()
    
    var comments = [Comment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(buttomView)
        buttomView.addSubview(sendButton)
        buttomView.addSubview(commentView)
    }
    
    func configureConstraint() {
        
    }
}

extension CommentController: UITableViewDelegate {
    
}

extension CommentController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
