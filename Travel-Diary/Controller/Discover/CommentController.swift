//
//  CommentController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/26.
//

import UIKit

class CommentController: UIViewController {
    var textViewHC: NSLayoutConstraint!
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "send"), for: .normal)
        button.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        return button
    }()
    
    let buttomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.7
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let buttomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    lazy var commentView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        
        view.clipsToBounds = true
        view.isScrollEnabled = false
        view.font = UIFont.systemFont(ofSize: 20)
        view.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        view.delegate = self
        return view
    }()
    
    let userPhoto: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 80
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        
        return table
    }()
    
    var journeyId: String?
    var comments = [Comment]()
    var showComments = [ShowComment]()
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(buttomView)
        buttomView.addSubview(buttomStackView)
        buttomStackView.addArrangedSubview(userPhoto)
        buttomStackView.addArrangedSubview(commentView)
        buttomStackView.addArrangedSubview(sendButton)
        configureConstraint()
    }
    
    func configureConstraint() {
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 16)
        buttomView.anchor(top: tableView.bottomAnchor,
                               left: view.leftAnchor,
                          bottom: view.bottomAnchor,
                               right: view.rightAnchor)
        buttomStackView.anchor(top: buttomView.topAnchor,
                               left: buttomView.leftAnchor,
                               bottom: buttomView.bottomAnchor,
                               right: buttomView.rightAnchor,
                               paddingTop: 16, paddingLeft: 16,
                               paddingBottom: 32, paddingRight: 16)
        userPhoto.setDimensions(width: 50, height: 50)
        sendButton.anchor(width: 32)
        sendButton.isHidden = true
        commentView.translatesAutoresizingMaskIntoConstraints = false
        textViewHC = commentView.heightAnchor.constraint(equalToConstant: 40)
        textViewHC.constant = commentView.contentSize.height
        commentView.layoutIfNeeded()
        commentView.layer.cornerRadius = commentView.frame.height * 0.5
    }
    
    func configureData() {
        AuthManager.shared.getUserInfo { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.user = user
                    let url = URL(string: user.profileImageUrl)
                    self?.userPhoto.kf.setImage(with: url)
                }
            case .failure(let error):
                self?.error404()
            }
        }
        fetchAllComments()
    }
    
    func fetchAllComments() {
        guard let journeyId = journeyId else { return }
        showComments.removeAll()
        CommentManager.shared.fetchAllComments(journeyId: journeyId) { [weak self] result in
            switch result {
            case .success(let comments):
                DispatchQueue.global().async {
                    let semaphore = DispatchSemaphore(value: 0)
                    for comment in comments {
                        AuthManager.shared.getUserInfo(uid: comment.userUID) { [weak self] result in
                            switch result {
                            case .success(let user):
                                let data = ShowComment(id: comment.id!,
                                                       journeyID: comment.journeyID,
                                                       username: user.username,
                                                       userPhoto: user.profileImageUrl,
                                                       comment: comment.comment,
                                                       commentTime: comment.commentTime)
                                self?.showComments.append(data)
                            case .failure(let error):
                                self?.error404()
                            }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            case .failure(let error):
                self?.error404()
            }
        }
    }
    
    func error404() {
        let alert = UIAlertController(title: "Error 404",
                                      message: "Please check your internet connect!",
                                      preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func sendComment() {
        guard let journeyId = journeyId else { return }
        let current = Date().millisecondsSince1970
        CommentManager.shared.sendComment(journeyId: journeyId,
                                          comment: commentView.text,
                                          commentTime: current) { [weak self] result in
            switch result {
            case .success:
                self?.commentView.text.removeAll()
                self?.sendButton.isHidden = true
                self?.fetchAllComments()
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}

extension CommentController: UITableViewDelegate {
    
}

extension CommentController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showComments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CommentCell.identifier,
            for: indexPath) as? CommentCell else { return UITableViewCell() }
        
        if let comment = showComments[safe: indexPath.row] {
            cell.configureData(username: comment.username,
                               profileImageUrl: comment.userPhoto,
                               comment: comment.comment,
                               commentTime: comment.commentTime)
        }
        
        return cell
    }
}

extension CommentController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let numberOfText = textView.text.count
        if numberOfText == 0 {
            sendButton.isHidden = true
        } else {
            sendButton.isHidden = false
        }
    }
}
