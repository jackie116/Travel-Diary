//
//  CommentController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/26.
//

import UIKit
import IQKeyboardManagerSwift

class CommentController: UIViewController {
    
    // MARK: - Properties
    var textViewHC: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var bottomTopConstraint: NSLayoutConstraint!
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "send"), for: .normal)
        button.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        return button
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.7
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    lazy var commentTextView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        
        view.clipsToBounds = true
        view.isScrollEnabled = false
        view.font = UIFont.systemFont(ofSize: 20)
        view.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        view.delegate = self
        return view
    }()
    
    let userImageView: UIImageView = {
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
    
    let animationView = LottieAnimation.shared.createLoopAnimation(lottieName: "emptyBox")
    
    var journeyId: String?
    var comments = [Comment]()
    var showComments = [ShowComment]()
    var user: User?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        setupUI()
        setupData()
    }
    
    deinit {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(bottomView)
        tableView.addSubview(animationView)
        bottomView.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(userImageView)
        bottomStackView.addArrangedSubview(commentTextView)
        bottomStackView.addArrangedSubview(sendButton)
        setupConstraint()
    }
    
    func setupConstraint() {
        animationView.center(inView: tableView)
        animationView.setDimensions(width: UIScreen.width * 0.4, height: UIScreen.width * 0.4)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 16)
        
        bottomView.anchor(top: tableView.bottomAnchor,
                          left: view.leftAnchor,
                          right: view.rightAnchor)
        
        bottomConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        
        bottomStackView.anchor(top: bottomView.topAnchor,
                               left: bottomView.leftAnchor,
                               bottom: bottomView.bottomAnchor,
                               right: bottomView.rightAnchor,
                               paddingTop: 16, paddingLeft: 16,
                               paddingBottom: 32, paddingRight: 16)
        
        userImageView.setDimensions(width: 50, height: 50)
        sendButton.anchor(width: 32)
        sendButton.isHidden = true
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        textViewHC = commentTextView.heightAnchor.constraint(equalToConstant: 40)
        textViewHC.constant = commentTextView.contentSize.height
        commentTextView.layoutIfNeeded()
        commentTextView.layer.cornerRadius = commentTextView.frame.height * 0.5
    }
    
    func setupData() {
        AuthManager.shared.getUserInfo { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.user = user
                    let url = URL(string: user.profileImageUrl)
                    self?.userImageView.kf.setImage(with: url)
                }
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
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
                                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                            }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.scrollToBottom()
                    }
                }
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    func scrollToBottom() {
        if showComments.count >= 1 {
            let indexPath = IndexPath(row: self.showComments.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Selector
    @objc func sendComment() {
        guard let journeyId = journeyId else { return }
        let current = Date().millisecondsSince1970
        CommentManager.shared.sendComment(journeyId: journeyId,
                                          comment: commentTextView.text,
                                          commentTime: current) { [weak self] result in
            switch result {
            case .success:
                self?.commentTextView.text.removeAll()
                self?.sendButton.isHidden = true
                self?.fetchAllComments()
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            let keyboardHeight = keyboardRectangle.height
            
            bottomConstraint.constant = -keyboardHeight
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 0
    }
}

// MARK: - UITableViewDelegate
extension CommentController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension CommentController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showComments.count != 0 {
            animationView.removeFromSuperview()
        }
        return showComments.count
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

// MARK: - UITextViewDelegate
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
